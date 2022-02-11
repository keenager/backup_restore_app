// import 'dart:io';
// import 'dart:async';

// void main() async {
//   Directory aaa = Directory(r'c:\users\keenager\documents\aaa1');
//   List fileList = [];
//   int dirCnt = 0;
//   int fileCnt = 0;
//   int other = 0;

//   Completer<List<dynamic>> completer = Completer();
//   aaa.list(recursive: true).listen(
//     (event) {
//       fileList.add(event);
//       if (event is File) {
//         fileCnt++;
//       } else if (event is Directory) {
//         dirCnt++;
//       } else {
//         other++;
//       }
//     },
//     onError: (e) {
//       print(e.toString());
//     },
//     onDone: () => completer.complete(fileList),
//   );

//   for (final e in await completer.future) {
//     print(e);
//   }

//   print(dirCnt);
//   print(fileCnt);
//   print(other);

// }
