# flutter_package_installer

Offers the ability to install, upgrade, and remove applications on Android devices.

## Getting Started

This project binds to the Android
[PackageInstaller](https://developer.android.com/reference/android/content/pm/PackageInstaller) API to allow installing, upgrading, and removing applications on Android devices.

## Usage

To use this plugin, add `packageinstaller` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

```yaml
dependencies:
  flutter_package_installer: ^0.0.1
```

### Installing an APK

To install an APK, use the `installFromFile` method:

```dart
import 'package:flutter_package_installer/flutter_package_installer.dart';

await PackageInstaller().installFromFile(file);
```
