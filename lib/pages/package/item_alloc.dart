import 'package:flutter/material.dart';

class ItemAllocPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ItemAllocPageState();
}

class ItemAllocPageState extends State<ItemAllocPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('加减快件'),
            centerTitle: true
        ),
        body: Container(
            child: Text('待开发')
        )
    );
  }
}