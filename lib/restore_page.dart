import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

final String userName = Platform.environment['username'] ?? '사용자 확인 불가';
final Map<String, String> targetDirs = Path(userName).targetDirs;

class RestorePage extends StatefulWidget {
  const RestorePage({Key? key}) : super(key: key);

  @override
  State<RestorePage> createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
  bool isBackupDir = false;
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
                  onPressed: _restoreProcess,
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
    for (final dir in dirList) {
      if (targetDirs.keys.any((key) => dir.path.contains(key))) {
        isBackupDir = true;
      }
    }
    backupStr = isBackupDir ? selectedStr : '백업 폴더가 아닙니다.';
    setState(() {});
  }

  void _restoreProcess() {
    if (!isBackupDir) {
      showSnackBar(context, '백업해놓은 폴더를 선택하세요.');
    } else {
      Directory backupDir = Directory(backupStr);
      List<FileSystemEntity> backupList = backupDir.listSync(recursive: false);
      // Map<String, String> myPathMap = Path(userName).targetDirs;

      //백업 디렉토리 내부를 순회
      for (final entity in backupList) {
        String srcDirName = path.basename(entity.path);

        //해당 요소가 맵에 없을 때
        // (= 혹시 백업과 무관한 폴더나 파일이 있을 때)
        if (!targetDirs.containsKey(srcDirName)) {
          continue;
        }

        Directory srcDir = Directory(entity.path);
        String mapValue = targetDirs[srcDirName]!;

        // 백업 대상이 특정 파일 하나인 경우
        if (srcDirName.contains('파일')) {
          Directory destDir = File(mapValue).parent;
          destDir.createSync();
          (srcDir.listSync().first as File).copySync(mapValue);
          continue;
        }

        //메모지의 경우만 당초와 다른 디렉토리로 복사되도록 설정
        if (srcDirName == '메모지') {
          mapValue = targetDirs[srcDirName]! + r'\임시';
        }

        //일반적인 경우
        Directory destDir = Directory(mapValue);
        destDir.createSync(recursive: true);
        copyFilesFolders(srcDir, destDir);
      }
      showSnackBar(context, '복사 완료!');
    }
  }
}
