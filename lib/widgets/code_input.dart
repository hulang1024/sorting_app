//编号（例如包裹编号、快件编号）输入，它封装了输入细节，可以是键盘输入，或者扫码。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CodeInput extends StatefulWidget {
  CodeInput({Key key, this.labelText, this.onDone}) : super(key: key);

  final String labelText;
  final CodeInputDoneCallback onDone;

  @override
  State<StatefulWidget> createState() =>
      CodeInputState(labelText: labelText, onDone: onDone);
}

typedef CodeInputDoneCallback = void Function(String);

class CodeInputState extends State<CodeInput> {
  CodeInputState({this.labelText, this.onDone});

  final String labelText;
  final CodeInputDoneCallback onDone;
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
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: this.labelText,
      ),
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      }
    );
  }
}