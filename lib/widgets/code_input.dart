//编号（例如集包编号、快件编号）输入，它封装了输入细节，可以是键盘输入，或者扫码。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CodeInput extends StatefulWidget {
  CodeInput({Key key, this.labelText, this.focusNode, this.onDone, this.autofocus = true}) : super(key: key);

  final String labelText;
  final CodeInputDoneCallback onDone;
  final bool autofocus;
  final FocusNode focusNode;

  @override
  State<StatefulWidget> createState() => CodeInputState();
}

typedef CodeInputDoneCallback = void Function(String);

class CodeInputState extends State<CodeInput> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: widget.focusNode ?? FocusNode(),
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 0),
      ),
      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
      onEditingComplete: () {
        widget.onDone(controller.text);
      },
    );
  }
}
