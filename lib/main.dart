import 'package:flutter/material.dart';
import 'package:flutter_test_app/backup_page.dart';
import 'package:flutter_test_app/restore_page.dart';

// 개별 삭제 기능 구현

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Copy App',
      initialRoute: '/',
      routes: {
        '/': (context) => BackupPage(),
        '/restore': (context) => RestorePage(),
      },
    );
  }
}
