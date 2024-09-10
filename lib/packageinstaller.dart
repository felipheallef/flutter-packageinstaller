import 'dart:io';

import 'packageinstaller_platform_interface.dart';

class PackageInstaller {
  Future<String?> getPlatformVersion() {
    return PackageInstallerPlatform.instance.getPlatformVersion();
  }

  Future<bool> canRequestPackageInstalls() {
    return PackageInstallerPlatform.instance.canRequestPackageInstalls();
  }

  Future<void> installFromFile(File file) {
    return PackageInstallerPlatform.instance.installFromFile(file.path);
  }
}
