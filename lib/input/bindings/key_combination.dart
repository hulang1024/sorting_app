import 'package:flutter/services.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/keyboard_models.dart';

/// 按键组合。
///
/// 通常表示一个组合按键例如Ctrl+A（显然，在移动端通常只有单键按下），也可表示多个相关的键。
class KeyCombination {
  KeyCombination(keys) {
    if (keys is List) {
      this.keys = keys;
    } else {
      this.keys = [keys];
    }
  }

  List<InputKey> keys;

  @override
  String toString() {
    return keys.map(toKeyString).join(' ');
  }

  /// 返回该按键组合在UI上的文本描述。
  String readableString({separator = ' '}) {
    return keys.map(getReadableKey).join(separator);
  }

  /// 将此按键组合与[pressedKeys]按照[matchingMode]表示的规则进行匹配。
  bool isPressed(KeyCombination pressedKeys, [KeyCombinationMatchingMode matchingMode = KeyCombinationMatchingMode.Any]) {
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

  bool get isNone => keys.length == 1 && keys[0] == InputKey.None;

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

  /// 返回[key]在UI上显示的文本描述。
  String getReadableKey(InputKey key) {
    if (isNumberKey(key)) {
      return '数字' + (key.index - InputKey.Num0.index).toString();
    } else if (InputKey.None == key) {
      return '';
    } else {
      return toKeyString(key);
    }
  }

  /// 返回[key]是否修饰按键。
  static bool isModifierKey(InputKey key) => [InputKey.Control, InputKey.Shift, InputKey.Alt, InputKey.Super].contains(key);

  /// 返回[key]是否数字按键。
  static bool isNumberKey(InputKey key) => InputKey.Num0.index <= key.index && key.index <= InputKey.Num9.index;

  /// 返回[key]的字符串表示。
  static String toKeyString(InputKey key) {
    return key.toString().substring('InputKey'.length + 1);
  }

  /// 根据一个[InputKey]的字符串表示返回[InputKey]。
  static InputKey fromKeyString(String keyString) {
    return InputKey.values.firstWhere((key) => toKeyString(key) == keyString, orElse: () => null);
  }

  /// 根据[RawKeyEvent]返回[KeyCombination]表示。
  static KeyCombination fromRawKeyEvent(RawKeyEvent event) {
    List<InputKey> keys = [];
    keys.add(fromLogicalKey(event.logicalKey));
    return KeyCombination(keys);
  }

  /// 根据[LogicalKeyboardKey]返回对应的[InputKey]。
  static InputKey fromLogicalKey(LogicalKeyboardKey key) {
    int keyId = key.keyId;
    if (48 <= keyId && keyId <= 57) {
      return InputKey.values[InputKey.Num0.index + (keyId - 48)];
    } else if (LogicalKeyboardKey.enter.keyId == keyId) {
      return InputKey.Enter;
    } else {
      return KAICOM_W571_KEY_MAP[keyId] ?? InputKey.None;
    }
  }
}

enum KeyCombinationMatchingMode {
  /// 匹配任意一个键。
  Any,
  /// 匹配完全相同的一组键。
  Exact,
}
