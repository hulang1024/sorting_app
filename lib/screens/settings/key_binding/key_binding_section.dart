import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sorting/input/bindings/action.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_bindings_manager.dart';

import 'key_binding_row.dart';

class KeyBindingSection extends StatefulWidget {
  KeyBindingSection({
    Key key,
    @required this.header,
    @required this.actions,
    this.focusAction,
    this.onChangeFocus,
  }) : super(key: key);

  final String header;
  final List<BindingAction> actions;
  final BindingAction focusAction;
  final void Function(BindingAction focusAction) onChangeFocus;

  @override
  State<StatefulWidget> createState() => KeyBindingSectionState();
}

class KeyBindingSectionState extends State<KeyBindingSection> {
  List<GlobalKey<KeyBindingRowState>> keyBindingRowKeys;

  @override
  void initState() {
    super.initState();
    keyBindingRowKeys = widget.actions.map((_) => GlobalKey<KeyBindingRowState>()).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<KeyBindingRow> keyBindingRows = [];
    int i = 0;
    widget.actions.forEach((action) {
      keyBindingRows.add(KeyBindingRow(
        key: keyBindingRowKeys[i++],
        action: action,
        bindings: action == GlobalAction.OK
          ? [KeyBinding([InputKey.OK], GlobalAction.OK)]
          : KeyBindingManager.getByAction(action),
        hasFocus: widget.focusAction == action,
        onChangeFocus: (hasFocus) {
          if (widget.onChangeFocus != null) {
            widget.onChangeFocus(hasFocus ? action : null);
          }
        },
      ));
    });

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(widget.header, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        ),
        ...keyBindingRows,
        if (widget.onChangeFocus != null)
          Container(
            width: double.infinity,
            child: RaisedButton(
              focusNode: FocusNode(skipTraversal: true),
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: onResetPressed,
              child: Text('重置为默认配置'),
            ),
          ),
      ],
    );
  }

  void onResetPressed() async {
    widget.onChangeFocus(null);

    keyBindingRowKeys.forEach((key) {
      key.currentState.restoreDefaults();
    });
  }
}