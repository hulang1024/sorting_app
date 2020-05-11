import 'package:sorting/input/bindings/key_binding.dart';

class DatabaseKeyBinding extends KeyBinding {
  int id;
  DatabaseKeyBinding(key, action, this.id) : super(key, action);
}