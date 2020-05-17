import 'package:flutter/material.dart';
import 'package:sorting/widgets/status.dart';

Status itemAllocStatus(code) => [
  Status(text: '已上传成功', color: Colors.green),
  Status(text: '未上传到服务器', color: Colors.orange),
  Status(text: '快件编号有误', color: Colors.red),
  Status(text: '不存在快件', color: Colors.red),
  Status(text: '不存在集包', color: Colors.red),
  Status(text: '快件和集包的目的地编号不相同', color: Colors.red),
  Status(text: '快件早已加到其它集包', color: Colors.red),
  Status(text: '集包未加快件', color: Colors.red),
][code];