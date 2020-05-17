import 'package:flutter/material.dart';
import 'package:sorting/widgets/status.dart';

Status packageStatus(code) => [
  Status(text: '创建成功', color: Colors.black87),
  Status(text: '未上传到服务器', color: Colors.orange),
  Status(text: '创建上传失败，已存在相同编号', color: Colors.red),
  Status(text: '创建上传失败，未查询到目的地编号', color: Colors.red),
  Status(text: '已删除', color: Colors.red),
][code];

Status deleteOpStatus(code) => [
  Status(text: '删除成功', color: Colors.green),
  Status(text: '等待上传', color: Colors.orange),
  Status(text: '删除失败，集包包含快件', color: Colors.red),
  Status(text: '删除失败，集包不存在', color: Colors.red),
][code];