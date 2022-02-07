import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

final List entryList = targetDirs.entries.toList();
List<bool> exist = List<bool>.generate(targetDirs.length, (int i) => false);
List<bool> isChecked = List<bool>.generate(targetDirs.length, (int i) => false);
bool isDelChecked = true;

class BackupPage extends StatelessWidget {
  const BackupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: Center(
        child: Text(
          '가져올 파일 또는 폴더를 선택한 뒤, 저장할 위치를 선택하세요.',
          style: TextStyle(fontSize: 17),
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: PickWidget(),
          ),
          AdditionalWidget(),
          CopyWidget(),
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
            checked: isAllChecked,
            onChanged: (bool? value) {
              setState(() {
                isAllChecked = value!;
                toggleChecked(value);
              });
            },
          ),
          title: Text('전체 선택'),
          trailing: Tooltip(
            message: '새로고침',
            child: IconButton(
              icon: Icon(FluentIcons.refresh),
              onPressed: () => setState(() {
                isAllChecked = false;
                toggleChecked(false);
              }),
            ),
          ),
        ),
        Divider(
          style: DividerThemeData(
            decoration: BoxDecoration(color: Colors.black),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: entryList.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                leading: Checkbox(
                  checked: exist[index] ? isChecked[index] : false,
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
                        ? Icon(FluentIcons.completed_solid, color: Colors.green)
                        : Icon(FluentIcons.unknown),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        entryList[index].value +
                            '\n' +
                            '폴더: ${dirCntList[index]}개, 파일: ${fileCntList[index]}개, 크기: ${convertSize(fileSizeList[index])}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                          icon: Icon(
                            FluentIcons.open_folder_horizontal,
                            size: 20,
                          ),
                        ),
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

class AdditionalWidget extends StatelessWidget {
  const AdditionalWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            child: Text('판결서 주문, 이유 기재례 & 법원 인증서'),
            onPressed: () {
              myDialog(
                context: context,
                title: '판결서 주문/이유, 인증서',
                content:
                    "'판결문 작성 관리 시스템' - [업무지원] - [인증서/주문/이유 내보내기] 메뉴를 이용하시면 됩니다.",
              );
            },
          ),
          TextButton(
            child: Text('한글 사용자 정의 데이터 파일'),
            onPressed: () {
              myDialog(
                context: context,
                title: '사용자가 정의한 "매크로, 상용구, 빠른 교정" 등의 데이터를 저장합니다.',
                content: '''\u2460 [도구] - [환경 설정] - [파일] 탭 선택
\u2461 [사용자 정의 데이터] 항목 내 [사용자 정의 데이터 저장하기] 클릭
\u2462 사용자 정의 데이터가 "*.UDF" 파일 형식으로 지정한 위치에 저장됩니다.''',
              );
            },
          ),
        ],
      ),
    );
  }
}

class CopyWidget extends StatefulWidget {
  const CopyWidget({Key? key}) : super(key: key);

  @override
  _CopyWidgetState createState() => _CopyWidgetState();
}

class _CopyWidgetState extends State<CopyWidget> {
  String destStr = '없음';
  void _backupProcess() {
    if (destStr == '없음') {
      showSnackbar(context, Snackbar(content: Text('백업 대상을 저장할 폴더를 선택하세요.')));
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
          copyFilesFolders(
              context: context,
              source: srcDir,
              destination: destDir,
              task: 'backup',
              delete: isDelChecked);
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

  String backupButtonName = '가져오기(백업) & 원본 삭제';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              child: Text('폴더 선택'),
              onPressed: selectFolder,
            ),
            SizedBox(width: 20),
            Text('선택된 폴더: ' + destStr),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: '삭제 후 우측 상단 새로고침 버튼을 누르면 결과를 확인할 수 있습니다.',
              child: SizedBox(
                child: Row(
                  children: [
                    Checkbox(
                      checked: isDelChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isDelChecked = value!;
                          backupButtonName =
                              isDelChecked ? '가져오기(백업) & 원본 삭제' : '가져오기(백업)';
                        });
                      },
                    ),
                    Text('백업 후 원본 삭제'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
            FilledButton(
              child: Text(backupButtonName),
              onPressed: _backupProcess,
            ),
          ],
        ),
      ],
    );
  }
}
