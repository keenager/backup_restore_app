import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PickFoldersFiles(targetDirs),
            CopyFiles(targetDirs),
          ],
        ),
      ),
    );
  }
}

class PickFoldersFiles extends StatelessWidget {
  final Map<String, String> dir;
  const PickFoldersFiles(this.dir, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pick(),
    );
  }

  // 리스트 뷰, 리스트 타일로 만들어 보기

  List<Widget> pick() {
    List<Widget> result = [];
    for (final entry in dir.entries) {
      String filesStr = fileDirNamesOf(entry.value);
      result.add(makeTextInContainer('타겟 폴더: ${entry.key} (${entry.value})'));
      result.add(makeTextInContainer('복사할 파일&폴더: $filesStr'));
      result.add(Divider(
        thickness: 1.5,
        indent: 20,
        endIndent: 20,
      ));
    }
    return result;
  }

  Widget makeTextInContainer(String str) {
    return Container(
      child: Text(str),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    );
  }

  String fileDirNamesOf(String dir) {
    List<FileSystemEntity> dirList = Directory(dir).listSync();
    String result = '';
    for (final entity in dirList) {
      if (entity is Directory) {
        var temp = List.from(entity.uri.pathSegments);
        temp.removeLast();
        result += 'Folder[' + temp.last + '] ';
      } else {
        result += entity.uri.pathSegments.last + ', ';
      }
    }
    return result;
  }
}

class CopyFiles extends StatefulWidget {
  final Map<String, String> dir;
  const CopyFiles(this.dir, {Key? key}) : super(key: key);

  @override
  _CopyFilesState createState() => _CopyFilesState();
}

class _CopyFilesState extends State<CopyFiles> {
  String destStr = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('선택된 폴더: ' + (destStr == '' ? '없음' : destStr)),
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
              onPressed: () {
                for (final entry in widget.dir.entries) {
                  Directory destDir = Directory(path.join(destStr, entry.key));
                  destDir.createSync();
                  copyFilesFolders(Directory(entry.value), destDir);
                }
                Process.run('explorer', [destStr]);
              },
            ),
          ],
        ),
      ],
    );
  }

  void selectFolder() async {
    // 폴더 선택
    destStr = await FilePicker.platform.getDirectoryPath() ?? '';
    setState(() {});
  }

  void copyFilesFolders(Directory src, Directory dest) {
    List<FileSystemEntity> srcList = src.listSync(recursive: false);
    for (var entity in srcList) {
      if (entity is Directory) {
        Directory newDir = Directory(
            path.join(dest.absolute.path, path.basename(entity.path)));
        newDir.createSync();
        copyFilesFolders(entity.absolute, newDir);
      } else if (entity is File) {
        entity.copySync(path.join(dest.path, path.basename(entity.path)));
      }
    }
  }
}
