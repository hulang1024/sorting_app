import 'package:sorting/input/bindings/key_combination.dart';

class KeyBinding {
  KeyCombination keyCombination;
  var action;

  KeyBinding(key, action) {
    if (key is KeyCombination) {
      this.keyCombination = key;
    } else {
      this.keyCombination = KeyCombination(key is List ? key : [key]);
    }
    this.action = action;
  }

  @override
  String toString() {
    return 'KeyBinding-(keyCombination: $keyCombination, action: $action)';
  }

}