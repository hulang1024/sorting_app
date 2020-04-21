import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class Screen extends StatefulWidget {
  Screen({this.title, this.homeAction = true, this.addPadding});

  final String title;
  final bool homeAction;
  final EdgeInsets addPadding;
}

abstract class ScreenState<T extends Screen> extends State<T> {
  String _title = '';
  get title => _title;
  set title(str) {
    assert(mounted);
    setState(() => _title = str);
  }

  EdgeInsets padding;

  @override
  void initState() {
    super.initState();

    _title = widget.title;

    padding = EdgeInsets.fromLTRB(8, 8, 8, 8);
    if (widget.addPadding != null) {
      padding += widget.addPadding;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        elevation: 0,
        backgroundColor: Theme.of(context).canvasColor,
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black87),
        textTheme: Theme.of(context).textTheme.copyWith(
          title: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: !widget.homeAction
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
      ),
      body: Container(
        padding: padding,
        child: render(context),
      ),
    );
  }

  // 屏幕内容
  @protected
  Widget render(BuildContext context);

  bool pop() {
    return Navigator.of(context).pop();
  }

  Future push(Screen screen) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future pushReplacement(Screen screen) {
    return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => screen));
  }
}
