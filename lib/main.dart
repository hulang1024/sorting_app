import 'package:flutter/material.dart';
import 'package:sorting/routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      routes: routes,
      initialRoute: '/login',
    );
  }
}
