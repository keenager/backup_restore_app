import 'package:backup_restore_app/common_func.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'path_map.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String selectedPath = '없음';
  final TextEditingController _inputController = TextEditingController();

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
              future: getFinalTargetDirs(),
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
                            trailing: defaultTargetDirs
                                    .containsKey(entryList[index].key)
                                ? null
                                : IconButton(
                                    icon: Icon(FluentIcons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ContentDialog(
                                            title: Text('삭제'),
                                            content: Text('삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(
                                                child: Text('Okay'),
                                                onPressed: () async {
                                                  final _prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await _prefs.remove(
                                                      entryList[index].key);
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                      );
                    }
                }
              },
            ),
          ),
          TextButton(
            child: Text('Tip'),
            onPressed: () => myDialog(
                context: context,
                title: '설정 파일 저장 위치',
                content:
                    "개별 사용자가 추가한 백업 리스트는 백업하는 폴더 내에 shared_preference.json 파일로 저장됩니다. \n이 파일을 삭제하면 나중에 '불러오기'를 할 때 일부 대상이 빠지게 됩니다."),
          ),
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
                  controller: _inputController,
                  placeholder: '이름을 입력하세요.',
                ),
              ),
              FilledButton(
                  child: Text('저장'),
                  onPressed: () async {
                    final _prefs = await SharedPreferences.getInstance();
                    await _prefs.setString(_inputController.text, selectedPath);
                    setState(() {});
                  }),
            ],
          )
        ],
      ),
    );
  }
}
