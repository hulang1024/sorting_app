import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
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
  List<KeyBinding> keyBindings = [
    KeyBinding([InputKey.Num1, InputKey.F1], 'delete'),
    KeyBinding([InputKey.Num2, InputKey.F2], 'add'),
    KeyBinding([InputKey.Num3, InputKey.F3], 'search'),
  ];

  @override
  Widget render(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _optionButton(
            name: 'delete',
            icon: Icons.remove,
            color: Colors.redAccent,
            text: '减件',
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          _optionButton(
            name: 'add',
            icon: Icons.add,
            color: Colors.blueAccent,
            text: '加件',
          ),
          Padding(padding: EdgeInsets.only(top: 8)),
          _optionButton(
            name: 'search',
            icon: Icons.find_in_page,
            color: Colors.green,
            text: '查询',
          ),
        ],
      ),
    );
  }

  @override
  void onKeyUp(RawKeyEvent event) {
    KeyCombination keyCombination = KeyCombination.fromRawKeyEvent(event);
    for (var binding in keyBindings) {
      if (binding.keyCombination.isPressed(keyCombination, KeyCombinationMatchingMode.Any)) {
        _enterScreen(binding.action);
        return;
      }
    }
    super.onKeyUp(event);
  }

  Widget _optionButton({String name, IconData icon, String text, Color color}) {
    return Container(
      height: 120,
      child: Material(
        elevation: 1.5,
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: color,
        child: InkWell(
          onTap: () {
            _enterScreen(name);
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
                Padding(padding: EdgeInsets.symmetric(vertical: 4),),
                Text(keyBindings.firstWhere((binding) => binding.action == name).keyCombination.readableString(separator: ' / '),
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enterScreen(String functionName) {
    switch (functionName) {
      case 'add':
        push(PackageItemAllocScreen(opType: 1));
        break;
      case 'delete':
        push(PackageItemAllocScreen(opType: 2));
        break;
      case 'search':
        push(PackageItemOpRecordSearchScreen());
        break;
    }
  }
}
