import 'package:flutter/material.dart';

class PackageSmartCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new PackageSmartCreatePageState();
}

class PackageSmartCreatePageState extends State<PackageSmartCreatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('智能建包'),
        centerTitle: true,
      ),
      body: Container(
        child: Text('待开发'),
      ),
    );
  }
}
