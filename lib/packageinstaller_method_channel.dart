import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'packageinstaller_platform_interface.dart';

/// An implementation of [PackageinstallerPlatform] that uses method channels.
class MethodChannelPackageinstaller extends PackageinstallerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('packageinstaller');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
