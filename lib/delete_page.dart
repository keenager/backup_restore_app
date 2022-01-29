import 'package:flutter/material.dart';
import 'dart:io';
import 'path_map.dart';

final String userName = Platform.environment['username'] ?? '사용자 확인 불가';
final Map<String, String> deleteDirs = Path(userName).deleteDirs;
final List<MapEntry<String, String>> entryList = deleteDirs.entries.toList();

class DeletePage extends StatelessWidget {
  const DeletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('해당 폴더를 열어 필요 없는 파일들을 삭제하세요.'),
      ),
      body: ListView.separated(
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
                      icon: Icon(Icons.open_in_browser),
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
