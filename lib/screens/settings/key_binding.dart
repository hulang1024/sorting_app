import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sorting/input/bindings/action.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import '../screen.dart';
import 'key_binding/key_binding_section.dart';

class KeyBindingScreen extends Screen {
  KeyBindingScreen() : super(title: '按键配置', homeAction: false, addPadding: EdgeInsets.all(-8));
  @override
  State<StatefulWidget> createState() => KeyBindingScreenState();
}

class KeyBindingScreenState extends ScreenState<KeyBindingScreen> {
  List<GlobalKey<KeyBindingSectionState>> _sectionKeys = [GlobalKey(), GlobalKey()];
  BindingAction _focusAction;
  @override
  Widget render(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: ListView(
        children: [
          KeyBindingSection(
            key: _sectionKeys[0],
            header: '通用',
            actions: [
              GlobalAction.OK,
            ],
          ),
          KeyBindingSection(
            key: _sectionKeys[1],
            header: '功能',
            actions: GLOBAL_ACTIONS,
            focusAction: _focusAction,
            onChangeFocus: changeFocus,
          ),
        ],
      ),
    );
  }

  @override
  void onKeyDown(KeyCombination keyCombination) {
    _sectionKeys.forEach((key) {
      key.currentState.keyBindingRowKeys.forEach((key) {
        key.currentState.onKeyDown(keyCombination);
      });
    });
  }

  void changeFocus(focusAction) {
    setState(() {
      _focusAction = focusAction;
    });
  }

}
