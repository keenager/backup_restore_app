import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

final String userName = Platform.environment['username'] ?? '사용자 확인 불가';

class BackupPage extends StatelessWidget {
  const BackupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가져오기'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.download),
              title: Text('가져오기'),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: Icon(Icons.upload),
              title: Text('내보내기'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/restore');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PickWidget(Path(userName).targetDirs),
          ),
          CopyWidget(Path(userName).targetDirs),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}

class PickWidget extends StatelessWidget {
  final Map<String, String> dir;
  const PickWidget(this.dir, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List entries = dir.entries.toList();
    List<String> exist = [];
    List<int> dirCntList = [];
    List<int> fileCntList = [];
    for (final entry in entries) {
      bool isThere = false;
      if (File(entry.value).existsSync()) {
        isThere = true;
        dirCntList.add(0);
        fileCntList.add(1);
      } else if (Directory(entry.value).existsSync()) {
        isThere = true;
        int fileCnt = 0, dirCnt = 0;
        List entities = Directory(entry.value).listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File) {
            fileCnt++;
          } else if (entity is Directory) {
            dirCnt++;
          }
        }
        fileCntList.add(fileCnt);
        dirCntList.add(dirCnt);
      } else {
        fileCntList.add(0);
        dirCntList.add(0);
      }
      exist.add(isThere ? '있음' : '없음');
    }
    return ListView.separated(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(entries[index].key),
          subtitle: Text(entries[index].value +
              '\n' +
              exist[index] +
              ' 폴더: ${dirCntList[index]}개, 파일: ${fileCntList[index]}개'),
          isThreeLine: true,
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  // String fileDirNamesOf(String dir) {
  //   List<FileSystemEntity> dirList = Directory(dir).listSync();
  //   String result = '';
  //   for (final entity in dirList) {
  //     if (entity is Directory) {
  //       var temp = List.from(entity.uri.pathSegments);
  //       temp.removeLast();
  //       result += 'Folder[' + temp.last + '] ';
  //     } else {
  //       result += entity.uri.pathSegments.last + ', ';
  //     }
  //   }
  //   return result;
  // }
}

class CopyWidget extends StatefulWidget {
  final Map<String, String> dir;
  const CopyWidget(this.dir, {Key? key}) : super(key: key);

  @override
  _CopyWidgetState createState() => _CopyWidgetState();
}

class _CopyWidgetState extends State<CopyWidget> {
  String destStr = '없음';

  void backupProcess() {
    if (destStr == '없음') {
      showSnackBar(context, '백업 대상을 저장할 폴더를 선택하세요.');
    } else {
      for (final entry in widget.dir.entries) {
        Directory destDir = Directory(path.join(destStr, entry.key));
        destDir.createSync();
        String srcStr = entry.value;
        if (FileSystemEntity.isFileSync(srcStr)) {
          copyFile(File(srcStr), destDir);
        } else {
          copyFilesFolders(Directory(srcStr), destDir);
        }
      }
      Process.run('explorer', [destStr]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('선택된 폴더: ' + destStr),
        SizedBox(
          height: 10,
        ),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text('폴더 선택'),
              onPressed: selectFolder,
            ),
            ElevatedButton(
              child: Text('복사'),
              onPressed: backupProcess,
            ),
          ],
        ),
      ],
    );
  }

  void selectFolder() async {
    // 폴더 선택
    destStr = await FilePicker.platform.getDirectoryPath() ?? '없음';
    setState(() {});
  }

  void copyFile(File src, Directory dest) {
    src.copySync(path.join(dest.path, path.basename(src.path)));
  }

  void delete(FileSystemEntity target) {
    target.deleteSync(recursive: true);
  }
}
