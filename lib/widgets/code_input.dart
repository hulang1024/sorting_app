import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
/// 一个编号（例如集包编号、快件编号）输入框。
///
/// 它封装了输入细节，可以是键盘输入，或者扫码。
class CodeInput extends StatefulWidget {
  CodeInput({Key key, this.labelText, this.focusNode, this.onDone, this.autofocus = true, this.suffixIcon}) : super(key: key);

  /// 标签。
  final String labelText;

  /// 当输入完成时的回调。
  ///
  /// 输入完成时机包括扫码完成、点击软键盘确定按钮时。
  final void Function(String) onDone;

  /// 是否自动聚焦。
  final bool autofocus;

  /// 后置图标。
  final IconData suffixIcon;

  /// 焦点
  final FocusNode focusNode;

  @override
  State<StatefulWidget> createState() => CodeInputState();
}

class CodeInputState extends State<CodeInput> {
  TextEditingController controller = TextEditingController();
  FocusNode _focusNode;

  // 扫码消息通道
  static const _messageChannel = const BasicMessageChannel('sorting/scan', StandardMessageCodec());

  @override
  void initState() {
    super.initState();

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      // 当有焦点时，将全局的平台消息处理器关联到该 [CodeInputState] 实例。
      if (_focusNode.hasFocus) {
        _messageChannel.setMessageHandler((result) async {
          controller.text = result;
          widget.onDone(controller.text);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.number,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(fontWeight: FontWeight.normal, letterSpacing: 0),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(vertical: 0),
        suffix: widget.suffixIcon == null ? null : InkWell(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          onTap: () {
            widget.onDone(controller.text);
          },
          child: Icon(widget.suffixIcon, color: Theme.of(context).primaryColor,),
        ),
      ),
      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
      onEditingComplete: () {
        widget.onDone(controller.text);
      },
    );
  }
}
