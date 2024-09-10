import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'packageinstaller_platform_interface.dart';

/// An implementation of [PackageInstallerPlatform] that uses method channels.
class MethodChannelPackageinstaller extends PackageInstallerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('packageinstaller');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool> canRequestPackageInstalls() async {
    final result =
        await methodChannel.invokeMethod<bool>('canRequestPackageInstalls');
    return result ?? false;
  }

  @override
  Future<void> installFromFile(String file) async {
    await methodChannel.invokeMethod('installFromFile', {'file': file});
  }
}
