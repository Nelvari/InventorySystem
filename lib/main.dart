import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_system/pages/home_page.dart';
import 'package:inventory_system/styles.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inisialisasi untuk desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
          backgroundColor: pageBgColor,
          body: HomePage(),
      ),
    );
  }
}