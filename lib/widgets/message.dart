import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Messager {
  static Future ok(msg) {
    return _showMsg(msg, Colors.lightGreen);
  }

  static Future info(msg) {
    return _showMsg(msg, Colors.white);
  }

  static Future warning(msg) {
    return _showMsg(msg, Colors.orange);
  }

  static Future error(msg) {
    return _showMsg(msg, Colors.red);
  }

  static Future _showMsg(msg, textColor) {
    return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.TOP,
      textColor: textColor,
      fontSize: 16,
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
    );
  }
}
