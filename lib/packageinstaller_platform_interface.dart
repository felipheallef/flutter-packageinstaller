import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'packageinstaller_method_channel.dart';

abstract class PackageInstallerPlatform extends PlatformInterface {
  /// Constructs a PackageinstallerPlatform.
  PackageInstallerPlatform() : super(token: _token);

  static final Object _token = Object();

  static PackageInstallerPlatform _instance = MethodChannelPackageinstaller();

  /// The default instance of [PackageInstallerPlatform] to use.
  ///
  /// Defaults to [MethodChannelPackageinstaller].
  static PackageInstallerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PackageInstallerPlatform] when
  /// they register themselves.
  static set instance(PackageInstallerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool> canRequestPackageInstalls() {
    throw UnimplementedError(
        'canRequestPackageInstalls() has not been implemented.');
  }

  Future<void> installFromFile(String file) {
    throw UnimplementedError('installFromFile() has not been implemented.');
  }
}
