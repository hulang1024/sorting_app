import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'action.dart';
import 'key_binding_store.dart';

List<KeyBinding> getDefaultGlobalKeyBindings() => [
  KeyBinding(InputKey.F6, GlobalAction.PackageCreateSmart),
  KeyBinding(InputKey.Num1, GlobalAction.PackageCreateSmart),

  KeyBinding(InputKey.F2, GlobalAction.PackageCreate),
  KeyBinding(InputKey.Num2, GlobalAction.PackageCreate),

  KeyBinding(InputKey.F1, GlobalAction.PackageDelete),
  KeyBinding(InputKey.Num4, GlobalAction.PackageDelete),

  KeyBinding(InputKey.F4, GlobalAction.ItemAlloc),
  KeyBinding(InputKey.Num5, GlobalAction.ItemAlloc),

  KeyBinding(InputKey.F3, GlobalAction.PackageSearch),
  KeyBinding(InputKey.Num7, GlobalAction.PackageSearch),

  KeyBinding(InputKey.F5, GlobalAction.ItemSearch),
  KeyBinding(InputKey.Num8, GlobalAction.ItemSearch),

  KeyBinding(InputKey.Num3, GlobalAction.ItemAllocDelete),
  KeyBinding(InputKey.Num6, GlobalAction.ItemAllocAdd),
  KeyBinding(InputKey.Num9, GlobalAction.ItemAllocSearch),
];

abstract class KeyBindingManager {
  static List<KeyBinding> _keyBindings;
  static KeyBindingStore keyBindingStore = KeyBindingStore();

  static Future<List<KeyBinding>> getKeyBindings() async {
    if (_keyBindings == null) {
      await load();
    }

    return _keyBindings;
  }

  static Future load() async {
    List<KeyBinding> keyBindings = await keyBindingStore.query();
    if (keyBindings.length > 0) {
      _keyBindings = keyBindings;
    } else {
      _keyBindings = getDefaultGlobalKeyBindings();
      await keyBindingStore.saveDefaults(_keyBindings);
    }
  }

  static List<KeyBinding> getByAction(action) {
    return _keyBindings.where((binding) => binding.action == action).toList();
  }

  static KeyBinding getByKeyCombination(KeyCombination keyCombination) {
    return _keyBindings.firstWhere((binding) => binding.keyCombination == keyCombination, orElse: () => null);
  }
}