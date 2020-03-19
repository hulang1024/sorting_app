import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Messager {
  static void ok(msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.CENTER,
        textColor: Colors.green
    );
  }

  static void info(msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.CENTER,
        textColor: Colors.black
    );
  }

  static void error(msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.CENTER,
        textColor: Colors.red
    );
  }
}