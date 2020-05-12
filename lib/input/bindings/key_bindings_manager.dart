import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'action.dart';
import 'key_binding_store.dart';

/// 全局默认按键绑定
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

/// 按键绑定管理
abstract class KeyBindingManager {
  static List<KeyBinding> _keyBindings = [];
  static KeyBindingStore keyBindingStore = KeyBindingStore();

  /// 返回是否已经加载
  static isLoaded() => _keyBindings != null && _keyBindings.isNotEmpty;

  /// 返回所有绑定
  static List<KeyBinding> getKeyBindings() => _keyBindings;

  /// 从本地数据库中加载所有按键绑定
  static Future<void> load() async {
    if (isLoaded()) return;
    List<KeyBinding> keyBindings = await keyBindingStore.query();
    if (keyBindings.isEmpty) {
      await keyBindingStore.saveDefaults(getDefaultGlobalKeyBindings());
      // 重新查询以返回DatabaseKeyBinding
      _keyBindings = await keyBindingStore.query();
    } else {
      _keyBindings = keyBindings;
    }
  }

  /// 从所有绑定中根据 action 查询匹配的按键绑定
  static List<KeyBinding> getByAction(action) {
    return _keyBindings.where((binding) => binding.action == action).toList();
  }

  /// 从所有绑定中根据按键查询第一个匹配的按键绑定
  ///
  /// 如果存在按键绑定则返回，否则返回null
  /// 我们允许一个按键绑定到多个不同的动作，因此要注意按键绑定注册的顺序
  static KeyBinding getByKeyCombination(KeyCombination keyCombination) {
    if (keyCombination.isNone) {
      return null;
    }
    return _keyBindings.firstWhere((binding) => binding.keyCombination == keyCombination, orElse: () => null);
  }
}