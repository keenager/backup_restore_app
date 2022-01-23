import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void copyFilesFolders(Directory src, Directory dest) {
  List<FileSystemEntity> srcList = src.listSync(recursive: false);
  for (var entity in srcList) {
    if (entity is Directory) {
      Directory newDir =
          Directory(path.join(dest.absolute.path, path.basename(entity.path)));
      newDir.createSync();
      copyFilesFolders(entity.absolute, newDir);
    } else if (entity is File) {
      entity.copySync(path.join(dest.path, path.basename(entity.path)));
    }
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
