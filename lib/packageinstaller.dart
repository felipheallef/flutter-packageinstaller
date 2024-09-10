import 'packageinstaller_platform_interface.dart';

class PackageInstaller {
  Future<String?> getPlatformVersion() {
    return PackageinstallerPlatform.instance.getPlatformVersion();
  }
}
