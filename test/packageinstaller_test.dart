import 'package:flutter_test/flutter_test.dart';
import 'package:packageinstaller/packageinstaller.dart';
import 'package:packageinstaller/packageinstaller_platform_interface.dart';
import 'package:packageinstaller/packageinstaller_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPackageinstallerPlatform
    with MockPlatformInterfaceMixin
    implements PackageinstallerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PackageinstallerPlatform initialPlatform = PackageinstallerPlatform.instance;

  test('$MethodChannelPackageinstaller is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPackageinstaller>());
  });

  test('getPlatformVersion', () async {
    Packageinstaller packageinstallerPlugin = Packageinstaller();
    MockPackageinstallerPlatform fakePlatform = MockPackageinstallerPlatform();
    PackageinstallerPlatform.instance = fakePlatform;

    expect(await packageinstallerPlugin.getPlatformVersion(), '42');
  });
}
