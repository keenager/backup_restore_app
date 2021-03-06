import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'path_map.dart';
import 'package:path/path.dart' as path;
import 'common_func.dart';

late List<bool> exist;
late List<bool> isChecked;
late Map<String, String> _targetMap;
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
      content: FutureBuilder(
        future: getFinalTargetDirs(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return ProgressBar();
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                _targetMap = snapshot.data;
                exist =
                    List<bool>.generate(snapshot.data.length, (int i) => false);
                isChecked =
                    List<bool>.generate(snapshot.data.length, (int i) => true);

                return Column(
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
                );
              }
          }
        },
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
  bool isAllChecked = true;

  @override
  Widget build(BuildContext context) {
    String convertSize(int byte) {
      if (byte < 52) {
        return byte.toString() + 'byte';
      } else if (byte < 52429) {
        return '약 ' + (byte / 1024).toStringAsFixed(1) + 'KB';
      } else {
        return '약 ' + (byte / 1048576).toStringAsFixed(1) + 'MB';
      }
    }

    void toggleChecked(bool value) {
      isChecked.replaceRange(0, _targetMap.length,
          List<bool>.generate(_targetMap.length, (int i) => value));
    }

    Future<Map<String, dynamic>> dirContents(Directory dir) {
      Map<String, dynamic> contentsMap = {
        'entityList': [],
        'dirCnt': 0,
        'fileCnt': 0,
        'size': 0,
      };
      Completer<Map<String, dynamic>> completer = Completer();
      dir.list(recursive: true).listen(
        (event) {
          contentsMap['entityList'].add(event);
          if (event is Directory) {
            contentsMap['dirCnt']++;
          } else if (event is File) {
            contentsMap['fileCnt']++;
            contentsMap['size'] += event.lengthSync();
          }
        },
        onError: (e) => contentsMap['entityList'].add(e.toString()),
        onDone: () => completer.complete(contentsMap),
      );
      return completer.future;
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
              onPressed: () async {
                await getFinalTargetDirs();
                isAllChecked = false;
                toggleChecked(false);
                setState(() {});
              },
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
            itemCount: _targetMap.length,
            itemBuilder: (context, index) {
              List entryList = _targetMap.entries.toList();
              File f = File(entryList[index].value);
              Directory d = Directory(entryList[index].value);
              if (f.existsSync() || d.existsSync()) exist[index] = true;
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
                    if (f.existsSync()) ...[
                      Flexible(
                        child: FutureBuilder(
                          future: f.length(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return ProgressBar();
                              default:
                                if (snapshot.hasError) {
                                  showSnackbar(
                                    context,
                                    Snackbar(
                                        content:
                                            Text(snapshot.error.toString())),
                                    duration: Duration(seconds: 5),
                                  );
                                  return Text(snapshot.error.toString());
                                } else {
                                  int fileSize =
                                      int.parse(snapshot.data!.toString());
                                  exist[index] = true;
                                  return Text(
                                    entryList[index].value +
                                        '\n' +
                                        '폴더: 0개, 파일: 1개, 크기: ${convertSize(fileSize)}',
                                    overflow: TextOverflow.ellipsis,
                                  );
                                }
                            }
                          },
                        ),
                      ),
                    ] else if (d.existsSync()) ...[
                      Flexible(
                        child: FutureBuilder(
                            future: dirContents(d),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return ProgressBar();
                                default:
                                  if (snapshot.hasError) {
                                    showSnackbar(
                                      context,
                                      Snackbar(
                                          content:
                                              Text(snapshot.error.toString())),
                                      duration: Duration(seconds: 5),
                                    );
                                    return Text(snapshot.error.toString());
                                  } else {
                                    Map<String, dynamic> result = snapshot.data;
                                    exist[index] =
                                        result['size'] > 0 ? true : false;
                                    return Text(
                                      entryList[index].value +
                                          '\n' +
                                          '폴더: ${result['dirCnt']}개, 파일: ${result['fileCnt']}개, 크기: ${convertSize(result['size'])}',
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                              }
                            }),
                      ),
                    ] else ...[
                      Text(
                        entryList[index].value + '\n' + 'Not Found',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]
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
            child: Text('한컴오피스 NEO 한글, 사용자 정의 데이터 파일'),
            onPressed: () {
              myDialog(
                context: context,
                title: '사용자가 정의한 "매크로, 상용구, 빠른 교정" 등의 데이터를 저장합니다.',
                content: '''\u2460 [도구] - [환경 설정] - [파일] 탭 선택
\u2461 [사용자 정의 데이터] 항목 내 [사용자 정의 데이터 저장하기] 클릭
\u2462 사용자 정의 데이터가 <*.UDF> 파일 형식으로 지정한 위치에 저장됩니다.''',
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

  void _backupProcess(Map<String, String> dirs) {
    if (!isChecked.contains(true)) {
      showSnackbar(context, Snackbar(content: Text('백업 대상을 하나 이상 선택하세요.')));
    } else if (destStr == '없음') {
      showSnackbar(context, Snackbar(content: Text('백업 대상을 저장할 폴더를 선택하세요.')));
    } else {
      int index = 0;
      dirs.forEach((key, value) {
        //백업 대상이 없거나 체크되지 않은 경우 스킵
        if (!exist[index] || !isChecked[index]) {
          index++;
          return;
        }
        //key 이름으로 하위 폴더 생성
        Directory destDir = Directory(path.join(destStr, key));
        destDir.createSync(recursive: true);
        //대상이 특정 파일 하나인 경우
        if (FileSystemEntity.isFileSync(value)) {
          copyFile(File(value), destDir);
          File(value).deleteSync(recursive: true);
        } else {
          //대상이 디렉토리인 경우
          Directory srcDir = Directory(value);
          copyFilesFolders(
              context: context,
              source: srcDir,
              destination: destDir,
              task: 'backup',
              delete: isDelChecked);
        }
        //if (isDelChecked) Directory(entry.value).deleteSync();
        index++;
      });
      copyFile(File(prefsPath), Directory(destStr));
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
                    Text('원본 삭제 여부'),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
            FilledButton(
              child: Text(backupButtonName),
              onPressed: () {
                _backupProcess(_targetMap);
              },
            ),
          ],
        ),
      ],
    );
  }
}
