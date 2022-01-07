import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;

class RestorePage extends StatefulWidget {
  const RestorePage({Key? key}) : super(key: key);

  @override
  State<RestorePage> createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
  String backupStr = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내보내기'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Text('백업 폴더: ' + (backupStr == '' ? '없음' : backupStr)),
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
                    Directory backupDir = Directory(backupStr);
                    List<FileSystemEntity> backupList =
                        backupDir.listSync(recursive: false);
                    for (final entity in backupList) {
                      if (entity is Directory) {
                        Directory destDir = Directory(
                            targetDirs2[path.basename(entity.path)] ?? '');
                        destDir.createSync();
                        copyFilesFolders(entity, destDir);
                      }
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void selectFolder() async {
    // 폴더 선택
    String? selectedStr = await FilePicker.platform.getDirectoryPath();
    if (selectedStr == null) return;

    List<FileSystemEntity> dirList = Directory(selectedStr).listSync();
    bool isThere = false;
    for (final dir in dirList) {
      if (targetDirs.keys.any((key) => dir.path.contains(key))) {
        isThere = true;
      }
    }
    backupStr = isThere == true ? selectedStr : '백업 폴더가 아닙니다.';
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
