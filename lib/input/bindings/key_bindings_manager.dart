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
  static List<KeyBinding> _keyBindings = [];
  static KeyBindingStore keyBindingStore = KeyBindingStore();

  static isLoaded() => _keyBindings != null && _keyBindings.isNotEmpty;
  static List<KeyBinding> getKeyBindings() => _keyBindings;

  static Future<void> load() async {
    if (isLoaded()) return;
    List<KeyBinding> keyBindings = await keyBindingStore.query();
    if (keyBindings.length > 0) {
      _keyBindings = keyBindings;
    } else {
      await keyBindingStore.saveDefaults(getDefaultGlobalKeyBindings());
      // 重新查询以返回DatabaseKeyBinding
      _keyBindings = await keyBindingStore.query();
    }
  }

  static List<KeyBinding> getByAction(action) {
    return _keyBindings.where((binding) => binding.action == action).toList();
  }

  static KeyBinding getByKeyCombination(KeyCombination keyCombination) {
    if (keyCombination.isNone) {
      return null;
    }
    return _keyBindings.firstWhere((binding) => binding.keyCombination == keyCombination, orElse: () => null);
  }
}