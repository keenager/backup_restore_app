import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.download),
            title: Text('가져오기'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('삭제하기'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/delete');
            },
          ),
          ListTile(
            leading: Icon(Icons.upload),
            title: Text('내보내기'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/restore');
            },
          ),
        ],
      ),
    );
  }
}
