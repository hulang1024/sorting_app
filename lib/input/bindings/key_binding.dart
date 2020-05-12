import 'package:sorting/input/bindings/key_combination.dart';

/// 按键绑定。
class KeyBinding {
  /// 按键组合。
  KeyCombination keyCombination;

  /// 按键绑定的动作。
  var action;

  KeyBinding(key, action) {
    if (key is KeyCombination) {
      this.keyCombination = key;
    } else {
      this.keyCombination = KeyCombination(key);
    }
    this.action = action;
  }

  @override
  String toString() {
    return 'KeyBinding-(keyCombination: $keyCombination, action: $action)';
  }

}