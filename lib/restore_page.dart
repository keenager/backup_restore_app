import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

late Map<String, String> targetMap;

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
    return ScaffoldPage(
      header: Center(
        child: Text(
          '가져왔던 파일 또는 폴더들을 배치합니다.',
          style: TextStyle(fontSize: 17),
        ),
      ),
      content: FutureBuilder(
        future: targetDirs,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return ProgressBar();
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                targetMap = snapshot.data;
                return Center(
                  child: Column(
                    children: [
                      SizedBox(height: 50),
                      Text('백업해놓은 폴더들을 포함하는 상위 폴더를 선택하세요.'),
                      Text(
                          "ex) '나무' 폴더 아래에 '즐겨찾기', '메모지' 등의 백업 폴더가 있는 경우, '나무' 폴더를 선택."),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            child: Text('폴더 선택'),
                            onPressed: selectBackupFolder,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                              '백업 폴더: ' + (backupStr == '' ? '없음' : backupStr)),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FilledButton(
                        child: Text('내보내기(복원)'),
                        onPressed: _restoreProcess,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        child: Text('메모지 복원 관련'),
                        onPressed: () {
                          myDialog(
                              context: context,
                              title: '메모지 복원 경로',
                              content: '백업해 둔 메모지 파일들은 모두 '
                                  r'[ C:\work\ps\mo\사용자메모지\임시 ] 폴더로 복사됩니다.'
                                  '\n'
                                  '복사한 뒤 메모지 프로그램을 실행하여 해당 부분 설명에 따라 메모지를 등록하시면 됩니다.');
                        },
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  void selectBackupFolder() async {
    // 폴더 선택
    String? selectedStr = await FilePicker.platform.getDirectoryPath();
    if (selectedStr == null) return;

    List<FileSystemEntity> dirList = Directory(selectedStr).listSync();
    for (final dir in dirList) {
      if (targetMap.keys.any((key) => dir.path.contains(key))) {
        isBackupDir = true;
      }
    }
    backupStr = isBackupDir ? selectedStr : '백업 폴더가 아닙니다.';
    setState(() {});
  }

  void _restoreProcess() {
    if (!isBackupDir) {
      showSnackbar(context, Snackbar(content: Text('백업해놓은 폴더를 선택하세요.')));
    } else {
      Directory backupDir = Directory(backupStr);
      List<FileSystemEntity> backupList = backupDir.listSync(recursive: false);
      // Map<String, String> myPathMap = Path(userName).targetDirs;

      //백업 디렉토리 내부를 순회
      for (final entity in backupList) {
        String srcDirName = path.basename(entity.path);

        //해당 요소가 맵에 없을 때
        // (= 혹시 백업과 무관한 폴더나 파일이 있을 때)
        if (!targetMap.containsKey(srcDirName)) {
          continue;
        }

        Directory srcDir = Directory(entity.path);
        String mapValue = targetMap[srcDirName]!;

        // 백업 대상이 특정 파일 하나인 경우
        if (srcDirName.contains('파일')) {
          Directory destDir = File(mapValue).parent;
          destDir.createSync();
          (srcDir.listSync().first as File).copySync(mapValue);
          continue;
        }

        //메모지의 경우만 당초와 다른 디렉토리로 복사되도록 설정
        if (srcDirName == '메모지') {
          mapValue = targetMap[srcDirName]! + r'\임시';
        }

        //일반적인 경우
        Directory destDir = Directory(mapValue);
        destDir.createSync(recursive: true);
        copyFilesFolders(
            context: context,
            source: srcDir,
            destination: destDir,
            task: 'restore');
      }
      showSnackbar(context, Snackbar(content: Text('복사 완료!')));
    }
  }
}
