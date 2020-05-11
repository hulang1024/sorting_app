import 'package:flutter/services.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/keyboard_model/kaicomw571.dart';

class KeyCombination {
  KeyCombination(this.keys);

  final List<InputKey> keys;

  @override
  String toString() {
    return keys.map(toKeyString).join(' ');
  }

  String readableString({separator = ' '}) {
    return keys.map(getReadableKey).join(separator);
  }

  bool isPressed(KeyCombination pressedKeys, KeyCombinationMatchingMode matchingMode) {
    switch (matchingMode) {
      case KeyCombinationMatchingMode.Any:
        for (var key in pressedKeys.keys) {
          if (keys.contains(key)) {
            return true;
          }
        }
        return false;
      case KeyCombinationMatchingMode.Exact:
        if (pressedKeys.keys.length != keys.length) {
          return false;
        }
        for (int i = 0; i < keys.length; i++) {
          if (pressedKeys.keys[i] != keys[i]) {
            return false;
          }
        }
        return true;
      default:
        return false;
    }
  }

  // ignore: hash_and_equals
  bool operator == (other) {
    if (other is InputKey) {
      return keys.length == 1 && other == keys[0];
    }
    if (!(other is KeyCombination)) {
      return false;
    }
    if (other.keys.length != keys.length) {
      return false;
    }
    for (int i = 0; i < keys.length; i++) {
      if (other.keys[i] != keys[i]) {
        return false;
      }
    }
    return true;
  }

  String getReadableKey(InputKey key) {
    if (isNumberKey(key)) {
      return '数字' + (key.index - InputKey.Num0.index).toString();
    } else if (InputKey.None == key) {
      return '';
    } else {
      return toKeyString(key);
    }
  }

  static bool isModifierKey(InputKey key) => [InputKey.Control, InputKey.Shift, InputKey.Alt, InputKey.Super].contains(key);
  static bool isNumberKey(InputKey key) => InputKey.Num0.index <= key.index && key.index <= InputKey.Num9.index;

  static String toKeyString(InputKey key) {
    return key.toString().substring('InputKey'.length + 1);
  }

  static InputKey fromKeyString(String keyString) {
    return InputKey.values.firstWhere((key) => toKeyString(key) == keyString);
  }

  static KeyCombination fromRawKeyEvent(RawKeyEvent event) {
    List<InputKey> keys = [];
    keys.add(fromLogicalKey(event.logicalKey));
    return KeyCombination(keys);
  }

  static InputKey fromLogicalKey(LogicalKeyboardKey key) {
    if (48 <= key.keyId && key.keyId <= 57) {
      return InputKey.values[InputKey.Num0.index + (key.keyId - 48)];
    } else if (LogicalKeyboardKey.enter.keyId == key.keyId) {
      return InputKey.Enter;
    } else {
      return KAICOM_W571_KEY_MAP[key.keyId] ?? InputKey.None;
    }
  }
}

enum KeyCombinationMatchingMode {
  /// 匹配任意一个键
  Any,
  /// 匹配完全相同的一组键
  Exact,
}
