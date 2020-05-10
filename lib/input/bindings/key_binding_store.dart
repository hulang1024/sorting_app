import 'package:sorting/dao/db_utils.dart';
import 'package:sorting/input/bindings/action.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'package:sqflite/sqflite.dart';
import 'key_binding.dart';

class KeyBindingStore {
  Future<void> saveDefaults(List<KeyBinding> defaults) async {
    var db = await getDB();
    Batch batch = db.batch();
    batch.delete('key_binding');
    for (KeyBinding binding in defaults) {
      assert (binding.action is BindingAction);
      batch.insert('key_binding', {'action': binding.action.code, 'keyCombination': binding.keyCombination.toString()});
    }
    await batch.commit();
  }

  Future<List<KeyBinding>> query() async {
    var db = await getDB();
    List<Map<String, dynamic>> records = await db.query('key_binding');
    return records.map((record) {
      BindingAction action = GLOBAL_ACTIONS.firstWhere((action) => action.code == record['action']);
      List<InputKey> keys = record['keyCombination'].toString().split(' ').map(KeyCombination.fromKeyString).toList();
      return KeyBinding(KeyCombination(keys), action);
    }).toList();
  }

  Future<void> update(KeyBinding binding) async {
    assert (binding.action is BindingAction);
    var db = await getDB();
    await db.update('key_binding',
      {'keyCombination': binding.keyCombination.toString()},
      where: 'action = ${binding.action.code}',
    );
  }

}