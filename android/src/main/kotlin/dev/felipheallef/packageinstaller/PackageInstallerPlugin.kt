package dev.felipheallef.packageinstaller

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageInstaller
import android.os.Build
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.NewIntentListener
import java.io.File
import java.io.FileInputStream

/** PackageinstallerPlugin */
class PackageInstallerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, NewIntentListener,
    ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "packageinstaller")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")

            }

            "canRequestPackageInstalls" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    result.success(activity?.packageManager?.canRequestPackageInstalls())
                } else {
                    result.success(true)
                }
            }

            "installFromFile" -> {
                val file = call.argument<String>("file")?.let { File(it) }

                if (file != null) {
                    installFromFile(file, result)
                } else {
                    result.error("argument_not_found", "Argument 'file' is required", null)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addOnNewIntentListener(this)
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    @SuppressLint("PrivateApi")
    private fun isMIUI(): Boolean {
        val refClass = Class.forName("android.os.SystemProperties")
        val get = refClass.getMethod("get", String::class.java)
        val miuiVersion = get.invoke(refClass, "ro.miui.ui.version.name") as String?
        return !miuiVersion.isNullOrBlank()
    }

    private fun createInstallerSession(): PackageInstaller.Session {
        val packageInstaller = activity?.packageManager?.packageInstaller
            ?: throw Exception("Not initialized")

        packageInstaller.mySessions.forEach {
            packageInstaller.abandonSession(it.sessionId)
        }

        val params =
            PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Xiaomi as always making our lives harder
            val value = if (isMIUI()) PackageInstaller.SessionParams.USER_ACTION_REQUIRED
            else PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED

            params.setRequireUserAction(value)
        }

        val sessionId = packageInstaller.createSession(params)
        return packageInstaller.openSession(sessionId)
    }

    private fun installFromFile(file: File, result: Result) {
        if (file.exists() && file.isFile && file.length() > 0) {
            val session = createInstallerSession()

            try {
                val packageInSession = session.openWrite("package", 0, file.length())
                val inputStream = FileInputStream(file)

                inputStream.copyTo(packageInSession)
                packageInSession.close()
                inputStream.close()

                val intent = Intent(activity!!, activity!!::class.java).apply {
                    action = PACKAGE_INSTALLED_ACTION
                }

                pendingResult = result
                activity!!.startActivity(intent)

                val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.getActivity(
                        activity,
                        REQUEST_INSTALL_PACKAGE,
                        intent,
                        PendingIntent.FLAG_MUTABLE
                    )
                } else {
                    PendingIntent.getActivity(activity, REQUEST_INSTALL_PACKAGE, intent, 0)
                }

                session.commit(pendingIntent.intentSender)
                Log.i(TAG, "Installation started")
            } catch (e: Exception) {
                e.printStackTrace()
                session.abandon()
                result.error("installFromFile", "Couldn't install package: ${e.message}", null)
            }
        } else {
            result.error("invalid_file", "The provided file is invalid", null)
        }
    }

    override fun onNewIntent(intent: Intent): Boolean {
        if (intent.action == PACKAGE_INSTALLED_ACTION) {
            intent.extras?.let { extras ->
                val status = extras.getInt(PackageInstaller.EXTRA_STATUS)
                val message = extras.getString(PackageInstaller.EXTRA_STATUS_MESSAGE)

                Log.i(TAG, "Status: $status")
                Log.i(TAG, "Message: $message")
                Log.i(TAG, "Result: ${pendingResult == null}")

                when (status) {
                    PackageInstaller.STATUS_PENDING_USER_ACTION -> {
                        val confirmIntent =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                extras.getParcelable(Intent.EXTRA_INTENT, Intent::class.java)
                            } else {
                                @Suppress("DEPRECATION")
                                extras.getParcelable(Intent.EXTRA_INTENT)
                            }

                        activity?.startActivity(confirmIntent)
                    }

                    PackageInstaller.STATUS_SUCCESS -> {
                        pendingResult?.success(null)
                        pendingResult = null
                    }

                    PackageInstaller.STATUS_FAILURE,
                    PackageInstaller.STATUS_FAILURE_ABORTED,
                    PackageInstaller.STATUS_FAILURE_BLOCKED,
                    PackageInstaller.STATUS_FAILURE_CONFLICT,
                    PackageInstaller.STATUS_FAILURE_INCOMPATIBLE,
                    PackageInstaller.STATUS_FAILURE_INVALID,
                    PackageInstaller.STATUS_FAILURE_STORAGE -> {
                        pendingResult?.error(
                            "installation_failed",
                            "Installation failed ($status): $message", null
                        )
                        pendingResult = null
                    }

                    else -> {
                        pendingResult?.error(
                            "unknown_status",
                            "Unrecognized status received from installer: $status", null
                        )
                        pendingResult = null
                    }
                }
            }
        }

        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
        Log.i(TAG, "Request code: $requestCode")
        return true
    }

    companion object {
        const val TAG = "PackageInstallerPlugin"
        const val REQUEST_INSTALL_PACKAGE = 10086
        const val PACKAGE_INSTALLED_ACTION =
            "dev.felipheallef.packageinstaller.SESSION_API_PACKAGE_INSTALLED"
    }
}
