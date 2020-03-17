import 'package:flutter/cupertino.dart';
import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/package_create.dart';
import 'pages/password_reset.dart';
import 'pages/register.dart';

var routes = <String, WidgetBuilder>{
  '/home':            (context) => HomePage(),
  '/login':           (context) => LoginPage(),
  '/register':        (context) => RegisterPage(),
  '/password_reset':  (context) => PasswordResetPage(),
  '/package_create':  (context) => PackageCreatePage(),
};