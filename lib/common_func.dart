import 'package:fluent_ui/fluent_ui.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void copyFilesFolders(
    {required BuildContext context,
    required Directory source,
    required Directory destination,
    required String task,
    bool delete = false}) {
  try {
    List<FileSystemEntity> srcList = source.listSync(recursive: false);
    for (var entity in srcList) {
      if (entity is Directory) {
        if (task == 'restore' &&
            source.path.contains('메모지') &&
            entity.path.contains('임시')) {
          copyFilesFolders(
              context: context,
              source: entity.absolute,
              destination: destination,
              task: task);
        } else {
          Directory newDir = Directory(
              path.join(destination.absolute.path, path.basename(entity.path)));
          newDir.createSync(recursive: true);
          copyFilesFolders(
              context: context,
              source: entity.absolute,
              destination: newDir,
              task: task,
              delete: delete);
        }
      } else if (entity is File) {
        entity
            .copySync(path.join(destination.path, path.basename(entity.path)));
      }
      if (delete) entity.deleteSync();
    }
  } catch (e) {
    showSnackbar(
      context,
      Snackbar(
        content: Text('에러가 생겼습니다. \n ${e.toString()}'),
      ),
      duration: Duration(seconds: 5),
    );
  }
}

void myDialog(
    {required BuildContext context,
    required String title,
    required String content}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
