import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_combination.dart';

class KeyButton extends StatefulWidget {
  KeyButton({Key key, this.keyBinding, this.onTap}) : super(key: key);

  final KeyBinding keyBinding;
  final void Function(KeyButton) onTap;

  @override
  State<StatefulWidget> createState() => KeyButtonState();
}

class KeyButtonState extends State<KeyButton> {
  bool _isBinding = false;
  KeyBinding _keyBinding;

  KeyCombination get keyCombination => _keyBinding.keyCombination;

  bool get isBinding => _isBinding;
  set isBinding(bool value) {
    setState(() {
      _isBinding = value;
    });
  }

  @override
  void initState() {
    super.initState();

    _keyBinding = widget.keyBinding;
  }

  @override
  Widget build(BuildContext context) {
    //与kaicom w571的实体按键颜色相同
    Color backgroundColor = Colors.black87;
    Color textColor = Colors.white.withOpacity(0.9);
    InputKey key = _keyBinding.keyCombination.keys[0]; // 目前只支持单个键
    switch (key) {
      case InputKey.F1:
        backgroundColor = Colors.red;
        break;
      case InputKey.F2:
        backgroundColor = Colors.blueAccent;
        break;
      case InputKey.F3:
        backgroundColor = Colors.green;
        break;
      case InputKey.F4:
        backgroundColor = Colors.yellow;
        break;
      case InputKey.None:
        backgroundColor = Colors.black87.withOpacity(0.1);
        break;
      default:
        if (KeyCombination.isNumberKey(key) || key == InputKey.OK)
          textColor = Colors.deepOrange;
        break;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      curve: Curves.easeOutQuint,
      width: 70,
      height: 28,
      decoration: BoxDecoration(
        color: _isBinding ? Colors.white : backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      child: GestureDetector(
        onTap: () {
          widget.onTap(widget);
        },
        child: Align(
          child: Container(
            width: double.infinity,
            child: Text(_keyBinding.keyCombination.readableString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _isBinding ? Colors.black : textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateKeyCombination(KeyCombination keyCombination) {
    setState(() {
      _keyBinding.keyCombination = keyCombination;
    });
  }
}