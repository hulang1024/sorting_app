import 'package:flutter/services.dart';

bool isOKKey(RawKeyEvent event) {
  return event.data.logicalKey.keyId == 0x100070028/*回车*/;//0x100070077;
}