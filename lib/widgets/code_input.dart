//编号（例如包裹编号、快件编号）输入，它封装了输入细节，可以是键盘输入，或者扫码。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CodeInput extends StatefulWidget {
  CodeInput({Key key, this.labelText, this.onDone, this.autofocus = true}) : super(key: key);

  final String labelText;
  final CodeInputDoneCallback onDone;
  final bool autofocus;

  @override
  State<StatefulWidget> createState() => CodeInputState();
}

typedef CodeInputDoneCallback = void Function(String);

class CodeInputState extends State<CodeInput> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: new FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          widget.onDone(controller.text);
        }
      },
      child: TextField(
        controller: controller,
        autofocus: widget.autofocus,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: widget.labelText,
        ),
      ),
    );
  }
}
