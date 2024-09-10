import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_package_installer/flutter_package_installer.dart';
import 'package:path/path.dart' show join;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _canRequestInstalls = false;

  final _plugin = PackageInstaller();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    bool canRequestInstalls = false;

    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      canRequestInstalls = await _plugin.canRequestPackageInstalls();
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _canRequestInstalls = canRequestInstalls;
    });
  }

  Future<void> _install() async {
    // just an example
    const String url = 'https://f-droid.org/repo/com.bobek.compass_23.apk';

    final dio = Dio();
    final file = File(join(
      Directory.systemTemp.path,
      Uri.parse(url).pathSegments.last,
    ));

    if (!(await file.exists())) {
      await dio.download(
        url,
        file.path,
        onReceiveProgress: (int count, int total) {
          print('Downloaded $count of $total bytes');
        },
      );
    }

    try {
      await _plugin.installFromFile(file);
    } on PlatformException catch (e, stack) {
      debugPrint(e.message);
      debugPrintStack(stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Can request package installs: $_canRequestInstalls'),
              FilledButton(
                onPressed: _install,
                child: const Text('Install App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
