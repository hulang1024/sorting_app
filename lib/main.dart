import 'package:flutter/material.dart';
import 'login.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        ),
        primarySwatch: Colors.blue,
        primaryColor: Colors.blueAccent,
      ),
      home: Login(),
    );
  }
}