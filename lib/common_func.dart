import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void copyFilesFolders(Directory src, Directory dest,
    {required String task, bool delete = false}) {
  try {
    List<FileSystemEntity> srcList = src.listSync(recursive: false);
    for (var entity in srcList) {
      if (entity is Directory) {
        if (task == 'restore' &&
            src.path.contains('메모지') &&
            entity.path.contains('임시')) {
          copyFilesFolders(entity.absolute, dest, task: task);
        } else {
          Directory newDir = Directory(
              path.join(dest.absolute.path, path.basename(entity.path)));
          newDir.createSync(recursive: true);
          copyFilesFolders(entity.absolute, newDir, task: task, delete: delete);
        }
      } else if (entity is File) {
        entity.copySync(path.join(dest.path, path.basename(entity.path)));
      }
      if (delete) entity.deleteSync();
    }
  } catch (e) {
    print(e);
  }
}

void showSnackBar(BuildContext ctx, String str) {
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(
      str,
      textAlign: TextAlign.center,
      style: TextStyle(),
    ),
    duration: Duration(seconds: 2),
  ));
}
