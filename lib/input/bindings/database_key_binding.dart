import 'package:sorting/input/bindings/key_binding.dart';

/// 数据库中的按键绑定实体。
///
/// 在修改相同[action]且不同[keyCombination]的多个[KeyBinding]时（例如某些[KeyBinding.keyCombination]都为[InputKey.None]），
/// 将不能从数据库表中唯一定位记录去执行update，因此该类增加一个[id]属性。
class DatabaseKeyBinding extends KeyBinding {
  int id;
  DatabaseKeyBinding(key, action, this.id) : super(key, action);
}