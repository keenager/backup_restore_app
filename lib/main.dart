import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test_app/backup_page.dart';
import 'package:flutter_test_app/restore_page.dart';
import 'package:flutter_test_app/delete_page.dart';
import 'path_map.dart';

// 개별 삭제 기능 구현(완료)     앱 아이콘

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'File Copy App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/backup': (context) => BackupPage(),
        '/delete': (context) => DeletePage(),
        '/restore': (context) => RestorePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text('$userName님, 안녕하세요.'),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        header: FlutterLogo(),
        items: [
          PaneItem(
            icon: Icon(FluentIcons.info),
            title: Text('안내'),
          ),
          PaneItem(
            icon: Icon(FluentIcons.download),
            title: Text('가져오기(백업)'),
          ),
          PaneItem(
            icon: Icon(FluentIcons.delete),
            title: Text('삭제하기'),
          ),
          PaneItem(
            icon: Icon(FluentIcons.upload),
            title: Text('내보내기(복원)'),
          ),
        ],
      ),
      content: NavigationBody(
        index: index,
        children: const [
          InstructionPage(),
          BackupPage(),
          DeletePage(),
          RestorePage(),
        ],
      ),
    );
  }
}

class InstructionPage extends StatelessWidget {
  const InstructionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    // Navigator.pushNamed(context, '/backup');
                  },
                  child: Text(
                    '가져오기(백업)',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/delete');
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
        Divider(size: MediaQuery.of(context).size.width * 0.5),
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
                // Navigator.pushNamed(context, '/restore');
              },
              child: Text(
                '내보내기(복원)',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
