import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void copyFilesFolders(Directory src, Directory dest, {bool delete = false}) {
  try {
    List<FileSystemEntity> srcList = src.listSync(recursive: false);
    for (var entity in srcList) {
      //사용자메모지 폴더 내의 다른 폴더는 복사할 필요가 없어서 제외.
      if (entity is Directory &&
          path.basename(entity.parent.path) != '사용자메모지') {
        Directory newDir = Directory(
            path.join(dest.absolute.path, path.basename(entity.path)));
        newDir.createSync(recursive: true);
        copyFilesFolders(entity.absolute, newDir, delete: delete);
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
