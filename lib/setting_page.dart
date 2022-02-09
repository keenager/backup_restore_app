import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String selectedPath = '없음';
  final TextEditingController inputController = TextEditingController();

  // Future<void> _addPath(String name, String path) async {
  //   final _prefs = await prefs;

  //   await _prefs.setString(name, path);
  //   targetDirs[name] = path;
  // }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Center(
        child: Text('백업할 대상을 추가, 삭제할 수 있습니다.'),
      ),
      content: Column(
        children: [
          Text('현재 백업 대상: '),
          Expanded(
            child: FutureBuilder<Map<String, String>>(
                future: targetDirs,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, String>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return ProgressBar();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List entryList = snapshot.data!.entries.toList();
                        return ListView.separated(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(entryList[index].key),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(),
                        );
                      }
                  }
                }),
          ),
          // Text('test: ${inputController.text}, $selectedPath'),
          // Text('$targetDirs'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                child: Text('폴더 선택'),
                onPressed: () async {
                  selectedPath =
                      await FilePicker.platform.getDirectoryPath() ?? '없음';
                  setState(() {});
                },
              ),
              SizedBox(
                width: 10,
              ),
              Text('선택한 폴더: $selectedPath'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('이름: '),
              Container(
                width: 250,
                padding: EdgeInsets.all(10),
                child: TextBox(
                  controller: inputController,
                  placeholder: '이름을 입력하세요.',
                ),
              ),
              FilledButton(
                  child: Text('저장'),
                  onPressed: () async {
                    final _prefs = await prefs;
                    await _prefs.setString(inputController.text, selectedPath);
                    getFinalTargetDirs();
                    setState(() {});
                  }),
            ],
          )
        ],
      ),
    );
  }
}
