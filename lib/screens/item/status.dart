import 'package:flutter/material.dart';
import 'package:sorting/widgets/status.dart';

Status itemStatus(alreadyAlloc) => alreadyAlloc
    ? Status(text: '已分配', color: Colors.green)
    : Status(text: '未分配', color: Colors.grey);
