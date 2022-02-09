import 'package:backup_restore_app/setting_page.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'backup_page.dart';
import 'restore_page.dart';
import 'delete_page.dart';
import 'path_map.dart';

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
        // '/backup': (context) => BackupPage(),
        // '/delete': (context) => DeletePage(),
        // '/restore': (context) => RestorePage(),
      },
    );
  }
}

final titleList = ['$userName님, 안녕하세요.', '가져오기(백업)', '삭제하기', '내보내기(복원)', '설정'];

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
        title: Center(
          child: Text(
            titleList[index],
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
      pane: NavigationPane(
        selected: index,
        onChanged: (i) => setState(() => index = i),
        header: Text('      메뉴'),
        items: [
          PaneItem(
            icon: Icon(FluentIcons.info),
            title: Text('안내'),
          ),
          PaneItem(
            icon: Icon(FluentIcons.download),
            title: Text(titleList[1]),
          ),
          PaneItem(
            icon: Icon(FluentIcons.delete),
            title: Text(titleList[2]),
          ),
          PaneItem(
            icon: Icon(FluentIcons.upload),
            title: Text(titleList[3]),
          ),
          PaneItem(
            icon: Icon(FluentIcons.settings),
            title: Text(titleList[4]),
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
          SettingPage(),
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
                  child: Row(
                    children: [
                      Icon(FluentIcons.download),
                      SizedBox(width: 10),
                      Text(
                        titleList[1],
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.pushNamed(context, '/delete');
                  },
                  child: Row(
                    children: [
                      Icon(FluentIcons.delete),
                      SizedBox(width: 10),
                      Text(
                        titleList[2],
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
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
              child: Row(
                children: [
                  Icon(FluentIcons.upload),
                  SizedBox(width: 10),
                  Text(
                    titleList[3],
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
