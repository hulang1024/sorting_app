import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sorting/input/bindings/action.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_binding_store.dart';
import 'package:sorting/input/bindings/key_bindings_manager.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'package:sorting/widgets/message.dart';

import 'key_button.dart';

class KeyBindingRow extends StatefulWidget {
  KeyBindingRow({
    Key key,
    @required this.action,
    @required this.bindings,
    @required this.hasFocus,
    @required this.onChangeFocus,
  }) : super(key: key);

  final BindingAction action;
  final List<KeyBinding> bindings;
  final bool hasFocus;
  final void Function(bool hasFocus) onChangeFocus;

  @override
  State<StatefulWidget> createState() => KeyBindingRowState();
}

class KeyBindingRowState extends State<KeyBindingRow> {
  static KeyBindingStore _keyBindingStore = KeyBindingStore();
  List<KeyButton> _keyButtons;
  KeyButton _bindTarget;
  KeyButtonState _keyButtonState([KeyButton button]) => ((button.key) as GlobalKey).currentState as KeyButtonState;
  KeyButtonState get _bindTargetState => _keyButtonState(_bindTarget);

  @override
  void initState() {
    super.initState();

    _keyButtons = widget.bindings.map((binding) =>
        KeyButton(
          key: GlobalKey(),
          keyBinding: binding,
          onTap: (target) {
            if (widget.action == GlobalAction.OK) {
              return;
            }
            if (widget.hasFocus) {
              if (_bindTarget == target && _bindTargetState.isBinding) {
                widget.onChangeFocus(false);
                return;
              }
              _bindTargetState.isBinding = false;
              _bindTarget = target;
              _bindTargetState.isBinding = true;
            } else {
              _bindTarget = target;
              _bindTargetState.isBinding = true;
              widget.onChangeFocus(true);
            }
          },
        )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.action == GlobalAction.OK) {
          Messager.info('不能改变该动作的按键');
          return;
        }
        widget.onChangeFocus(true);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
        height: widget.hasFocus ? 70 : 36,
        margin: EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(widget.action.text, style: TextStyle(color: Colors.white),),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        ..._keyButtons.map((btn) =>
                            Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: btn,
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
              if (widget.hasFocus)
                Container(
                  height: 28,
                  margin: EdgeInsets.only(top: 6),
                  child: ButtonBar(
                    buttonPadding: EdgeInsets.zero,
                    buttonHeight: 26,
                    buttonMinWidth: 70,
                    children: [
                      if (widget.hasFocus)
                        Text('按下按键以修改', style: TextStyle(fontSize: 12),),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 6),),
                      FlatButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text('取消'),
                        onPressed: onCancelPressed,
                      ),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 4),),
                      FlatButton(
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        child: Text('置空'),
                        onPressed: onClearPressed,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(KeyBindingRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hasFocus) {
      if (_bindTarget == null) {
        _bindTarget = _keyButtons[0];
        _bindTargetState.isBinding = true;
      }
    } else {
      if(_bindTarget != null) {
        _bindTargetState.isBinding = false;
        _bindTarget = null;
      }
    }
  }

  void onKeyDown(KeyCombination keyCombination) {
    if (!widget.hasFocus || _bindTarget == null) {
      return;
    }

    if (keyCombination.isNone) {
      Messager.warning('不支持的按键');
      return;
    }
    _bindTargetState.updateKeyCombination(keyCombination);
    _keyBindingStore.update(_bindTarget.keyBinding);
    widget.onChangeFocus(false);
  }

  void onCancelPressed() {
    widget.onChangeFocus(false);
  }

  void onClearPressed() {
    widget.onChangeFocus(false);

    _bindTargetState.updateKeyCombination(KeyCombination(InputKey.None));
    _keyBindingStore.update(_bindTarget.keyBinding);
  }

  void restoreDefaults() async {
    var defaults = getDefaultGlobalKeyBindings().where((binding) => binding.action == widget.action).toList();
    int i = 0;
    for (KeyBinding d in defaults) {
      KeyButton button = _keyButtons[i++];
      _keyButtonState(button).updateKeyCombination(d.keyCombination);
      _keyBindingStore.update(button.keyBinding);
    }
  }
}