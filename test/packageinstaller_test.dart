import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_package_installer/flutter_package_installer.dart';
import 'package:flutter_package_installer/packageinstaller_platform_interface.dart';
import 'package:flutter_package_installer/packageinstaller_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPackageinstallerPlatform
    with MockPlatformInterfaceMixin
    implements PackageInstallerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> canRequestPackageInstalls() => Future.value(true);

  @override
  Future<void> installFromFile(String file) => Future.value();
}

void main() {
  final PackageInstallerPlatform initialPlatform =
      PackageInstallerPlatform.instance;

  test('$MethodChannelPackageinstaller is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPackageinstaller>());
  });

  test('getPlatformVersion', () async {
    PackageInstaller packageinstallerPlugin = PackageInstaller();
    MockPackageinstallerPlatform fakePlatform = MockPackageinstallerPlatform();
    PackageInstallerPlatform.instance = fakePlatform;

    expect(await packageinstallerPlugin.getPlatformVersion(), '42');
  });
}
