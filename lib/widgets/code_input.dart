//编号（例如包裹编号、快件编号）输入，它封装了输入细节，可以是键盘输入，或者扫码。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../utils/key_utils.dart';

class CodeInput extends StatefulWidget {
  CodeInput({Key key, this.labelText, this.onDone, this.autofocus = true}) : super(key: key);

  final String labelText;
  final CodeInputDoneCallback onDone;
  final bool autofocus;

  @override
  State<StatefulWidget> createState() =>
      CodeInputState(labelText: labelText, onDone: onDone, autofocus: autofocus);
}

typedef CodeInputDoneCallback = void Function(String);

class CodeInputState extends State<CodeInput> {
  CodeInputState({this.labelText, this.onDone, this.autofocus});

  final String labelText;
  final CodeInputDoneCallback onDone;
  final bool autofocus;
  TextEditingController controller = new TextEditingController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        onDone(controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),// 焦点
      onKey: (RawKeyEvent event){
        if(isOKKey(event)) {
          onDone(controller.text);
        }
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: this.labelText,
        ),
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        }
      )
    );
  }
}