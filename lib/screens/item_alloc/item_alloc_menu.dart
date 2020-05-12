import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sorting/input/bindings/action.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_bindings_manager.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'package:sorting/screens/screen.dart';
import 'item_alloc.dart';
import 'search.dart';

class PackageItemAllocMenuScreen extends Screen {
  PackageItemAllocMenuScreen() : super(title: '选择操作', );

  @override
  State<StatefulWidget> createState() => _PackageItemAllocMenuScreenState();
}

class _PackageItemAllocMenuScreenState extends ScreenState<PackageItemAllocMenuScreen> {

  @override
  Widget render(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _optionButton(
            action: GlobalAction.ItemAllocDelete,
            icon: Icons.remove,
            color: Colors.redAccent,
            text: '减件',
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          _optionButton(
            action: GlobalAction.ItemAllocAdd,
            icon: Icons.add,
            color: Colors.blueAccent,
            text: '加件',
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          _optionButton(
            action: GlobalAction.ItemAllocSearch,
            icon: Icons.find_in_page,
            color: Colors.green,
            text: '查询',
          ),
        ],
      ),
    );
  }

  @override
  void onKeyUp(KeyCombination keyCombination) {
    KeyBinding binding = KeyBindingManager.getByKeyCombination(keyCombination);
    if (binding != null) {
      _enterScreen(binding.action);
    }
    super.onKeyUp(keyCombination);
  }

  Widget _optionButton({GlobalAction action, IconData icon, String text, Color color}) {
    String keysText = KeyBindingManager.getByAction(action)
        .where((binding) => !binding.keyCombination.isNone)
        .map((binding) => binding.keyCombination.readableString())
        .join(' / ');
    return Container(
      height: 120,
      child: Material(
        elevation: 1.5,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: color,
        child: InkWell(
          onTap: () {
            _enterScreen(action);
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(icon, color: Colors.white, size: 20),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 4),),
                    Text(text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (keysText.isNotEmpty) ...[
                  Padding(padding: EdgeInsets.symmetric(vertical: 4),),
                  Text(keysText,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enterScreen(GlobalAction action) {
    switch (action) {
      case GlobalAction.ItemAllocDelete:
        push(PackageItemAllocScreen(opType: 2));
        break;
      case GlobalAction.ItemAllocAdd:
        push(PackageItemAllocScreen(opType: 1));
        break;
      case GlobalAction.ItemAllocSearch:
        push(PackageItemAllocSearchScreen());
        break;
    }
  }
}
