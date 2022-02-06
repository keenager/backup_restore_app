import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'path_map.dart';

final Map<String, String> deleteDirs = Path(userName).deleteDirs;
final List<MapEntry<String, String>> entryList = deleteDirs.entries.toList();

class DeletePage extends StatelessWidget {
  const DeletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Center(
        child: Text(
          '해당 폴더를 열어 필요 없는 파일들을 삭제하세요.',
          style: TextStyle(fontSize: 15),
        ),
      ),
      content: ListView.separated(
        itemCount: entryList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(entryList[index].key),
            trailing: Directory(entryList[index].value).existsSync()
                ? Tooltip(
                    message: '누르면 해당 폴더가 열립니다.',
                    child: IconButton(
                      onPressed: () {
                        Process.run('explorer', [entryList[index].value]);
                      },
                      icon: Icon(
                        FluentIcons.open_folder_horizontal,
                        size: 20,
                      ),
                    ),
                  )
                : Text('Not found.'),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}
