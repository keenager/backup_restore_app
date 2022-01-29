import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test_app/drawer.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

final String userName = Platform.environment['username'] ?? '사용자 확인 불가';
final Map<String, String> targetDirs = Path(userName).targetDirs;
final List entryList = targetDirs.entries.toList();
List<bool> exist = List<bool>.generate(targetDirs.length, (int i) => false);
List<bool> isChecked = List<bool>.generate(targetDirs.length, (int i) => false);
bool isDelChecked = true;

class BackupPage extends StatelessWidget {
  const BackupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('가져오기'),
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: PickWidget(),
          ),
          DeleteWidget(),
          CopyWidget(),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            tooltip: '다음 페이지로(삭제하기)',
            onPressed: () {
              Navigator.pushNamed(context, '/delete');
            },
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}

class PickWidget extends StatefulWidget {
  const PickWidget({Key? key}) : super(key: key);

  @override
  State<PickWidget> createState() => _PickWidgetState();
}

class _PickWidgetState extends State<PickWidget> {
  bool isAllChecked = false;

  @override
  Widget build(BuildContext context) {
    List<int> dirCntList = [];
    List<int> fileCntList = [];
    List<int> fileSizeList = [];

    entryList.asMap().forEach((index, entry) {
      File f = File(entry.value);
      Directory d = Directory(entry.value);

      if (f.existsSync()) {
        // 타겟과 일치하는 파일이 있는 경우
        dirCntList.add(0);
        fileCntList.add(1);
        fileSizeList.add(f.lengthSync());
        exist[index] = true;
      } else if (d.existsSync()) {
        // 타겟과 일치하는 디렉토리가 있는 경우
        int fileCnt = 0, dirCnt = 0, size = 0;
        List<FileSystemEntity> entities = d.listSync(recursive: true);
        for (final entity in entities) {
          if (entity is File) {
            fileCnt++;
            size += entity.lengthSync();
          } else if (entity is Directory) {
            dirCnt++;
          }
        }
        dirCntList.add(dirCnt);
        fileCntList.add(fileCnt);
        fileSizeList.add(size);
        exist[index] = size > 0 ? true : false;
      } else {
        // 타겟이 없는 경우
        dirCntList.add(0);
        fileCntList.add(0);
        fileSizeList.add(0);
        exist[index] = false;
      }
    });

    void toggleChecked(bool value) {
      isChecked.replaceRange(0, targetDirs.length,
          List<bool>.generate(targetDirs.length, (int i) => value));
    }

    String convertSize(int byte) {
      if (byte < 52) {
        return byte.toString() + 'byte';
      } else if (byte < 52429) {
        return '약 ' + (byte / 1024).toStringAsFixed(1) + 'KB';
      } else {
        return '약 ' + (byte / 1048576).toStringAsFixed(1) + 'MB';
      }
    }

    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            value: isAllChecked,
            onChanged: (bool? value) {
              setState(() {
                isAllChecked = value!;
                toggleChecked(value);
              });
            },
          ),
          title: Text('전체 선택'),
          trailing: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isAllChecked = false;
                toggleChecked(false);
              });
            },
          ),
        ),
        Divider(color: Colors.black87),
        Expanded(
          child: ListView.separated(
            itemCount: entryList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Checkbox(
                  value: exist[index] ? isChecked[index] : false,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked[index] = value!;
                    });
                  },
                ),
                title: Text(entryList[index].key),
                subtitle: Row(
                  children: [
                    exist[index] == true
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.quiz_rounded),
                    SizedBox(
                      width: 10,
                    ),
                    Text(entryList[index].value +
                        '\n' +
                        '폴더: ${dirCntList[index]}개, 파일: ${fileCntList[index]}개, 크기: ${convertSize(fileSizeList[index])}'),
                  ],
                ),
                isThreeLine: true,
                trailing: exist[index] == true
                    ? Tooltip(
                        message: '누르면 해당 폴더가 열립니다.',
                        child: IconButton(
                            onPressed: () {
                              Process.run('explorer', [entryList[index].value]);
                            },
                            icon: Icon(Icons.open_in_browser)),
                      )
                    : null,
              );
            },
            separatorBuilder: (context, index) => Divider(),
          ),
        ),
      ],
    );
  }
}

class DeleteWidget extends StatefulWidget {
  const DeleteWidget({Key? key}) : super(key: key);

  @override
  _DeleteWidgetState createState() => _DeleteWidgetState();
}

class _DeleteWidgetState extends State<DeleteWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Tooltip(
            message: '삭제 후 우측 상단 새로고침 버튼을 누르면 결과를 확인할 수 있습니다.',
            child: Checkbox(
              value: isDelChecked,
              onChanged: (bool? value) {
                setState(() {
                  isDelChecked = value!;
                  print(isDelChecked);
                });
              },
            ),
          ),
          Text('백업 후 원본 삭제'),
        ],
      ),
    );
  }
}

class CopyWidget extends StatefulWidget {
  // final List<bool>? exist;
  const CopyWidget({Key? key}) : super(key: key);

  @override
  _CopyWidgetState createState() => _CopyWidgetState();
}

class _CopyWidgetState extends State<CopyWidget> {
  String destStr = '없음';
  void _backupProcess() {
    if (destStr == '없음') {
      showSnackBar(context, '백업 대상을 저장할 폴더를 선택하세요.');
    } else {
      entryList.asMap().forEach((index, entry) {
        //백업 대상이 없거나 체크되지 않은 경우 스킵
        if (!exist[index] || !isChecked[index]) {
          return;
        }
        //key 이름으로 하위 폴더 생성
        Directory destDir = Directory(path.join(destStr, entry.key));
        destDir.createSync(recursive: true);
        //대상이 특정 파일 하나인 경우
        if (FileSystemEntity.isFileSync(entry.value)) {
          copyFile(File(entry.value), destDir);
          File(entry.value).deleteSync(recursive: true);
        } else {
          //대상이 디렉토리인 경우
          Directory srcDir = Directory(entry.value);
          copyFilesFolders(srcDir, destDir,
              task: 'backup', delete: isDelChecked);
        }
        //if (isDelChecked) Directory(entry.value).deleteSync();
      });
      Process.run('explorer', [destStr]);
    }
  }

  void selectFolder() async {
    // 폴더 선택
    destStr = await FilePicker.platform.getDirectoryPath() ?? '없음';
    setState(() {});
  }

  void copyFile(File src, Directory dest) {
    src.copySync(path.join(dest.path, path.basename(src.path)));
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
              onPressed: _backupProcess,
            ),
          ],
        ),
      ],
    );
  }
}
