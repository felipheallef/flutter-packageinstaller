import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'packageinstaller_method_channel.dart';

abstract class PackageinstallerPlatform extends PlatformInterface {
  /// Constructs a PackageinstallerPlatform.
  PackageinstallerPlatform() : super(token: _token);

  static final Object _token = Object();

  static PackageinstallerPlatform _instance = MethodChannelPackageinstaller();

  /// The default instance of [PackageinstallerPlatform] to use.
  ///
  /// Defaults to [MethodChannelPackageinstaller].
  static PackageinstallerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PackageinstallerPlatform] when
  /// they register themselves.
  static set instance(PackageinstallerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
