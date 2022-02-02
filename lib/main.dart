import 'package:flutter/material.dart';
import 'package:flutter_test_app/backup_page.dart';
import 'package:flutter_test_app/restore_page.dart';
import 'package:flutter_test_app/delete_page.dart';
import 'package:flutter_test_app/drawer.dart';
import 'path_map.dart';

// 개별 삭제 기능 구현(완료)     앱 아이콘

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
        '/': (context) => MainPage(),
        '/backup': (context) => BackupPage(),
        '/delete': (context) => DeletePage(),
        '/restore': (context) => RestorePage(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('$userName님, 안녕하세요.'),
      ),
      drawer: MyDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    '종전 PC에서',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/backup');
                    },
                    child: Text(
                      '가져오기(백업)',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/delete');
                    },
                    child: Text(
                      '삭제하기',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            height: 30,
            indent: 230,
            endIndent: 230,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 15,
              ),
              Text(
                '새 PC에서',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(
                width: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/restore');
                },
                child: Text(
                  '내보내기(복원)',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
