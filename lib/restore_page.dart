import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

final String userName = Platform.environment['username'] ?? '사용자 확인 불가';

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
                  onPressed: restoreProcess,
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
      if (Path(userName).targetDirs.keys.any((key) => dir.path.contains(key))) {
        isBackupDir = true;
      }
    }
    backupStr = isBackupDir ? selectedStr : '백업 폴더가 아닙니다.';
    setState(() {});
  }

  void restoreProcess() {
    if (!isBackupDir) {
      showSnackBar(context, '백업해놓은 폴더를 선택하세요.');
    } else {
      Directory backupDir = Directory(backupStr);
      List<FileSystemEntity> backupList = backupDir.listSync(recursive: false);
      Map<String, String> myPathMap = Path(userName).targetDirs2;
      //배포판에서는 targetDir로 통합
      //통합에 수반되는 코드 수정 필요.

      //백업 디렉토리 내부를 순회
      for (final entity in backupList) {
        String srcDirName = path.basename(entity.path);

        //해당 요소가 맵에 없을 때
        // (= 혹시 백업과 무관한 폴더나 파일이 있을 때)
        if (!myPathMap.containsKey(srcDirName)) {
          continue;
        }

        Directory srcDir = Directory(entity.path);
        String mapValue = myPathMap[srcDirName]!;

        //해당 요소에 파일 하나만 들어 있는 경우
        // (= 백업 대상이 파일 하나)
        List inner = srcDir.listSync(recursive: false);
        if (inner.length == 1 && inner[0] is File) {
          Directory destDir = File(mapValue).parent;
          destDir.createSync();
          copyFile(inner[0], destDir, path.basename(mapValue));
          continue;
        }

        //일반적인 경우
        Directory destDir = Directory(mapValue);
        destDir.createSync();
        copyFilesFolders(srcDir, destDir);
      }
      showSnackBar(context, '복사 완료!');
    }
  }

  //배포 버전에서는 백업 부분과 같아질 듯 하므로 copy_func.dart로 통합
  void copyFile(File src, Directory dest, String str) {
    src.copySync(path.join(dest.path, str));
  }
}
