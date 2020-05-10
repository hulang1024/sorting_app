import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/input/bindings/key_binding.dart';
import 'package:sorting/input/bindings/key_bindings_manager.dart';
import 'package:sorting/input/bindings/action.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_combination.dart';
import 'package:sorting/session.dart';
import 'package:sorting/widgets/message.dart';
import 'item/search.dart';
import 'item_alloc/item_alloc_menu.dart';
import 'menu/main_menu.dart';
import 'package/create.dart';
import 'package/delete.dart';
import 'package/search.dart';
abstract class Screen extends StatefulWidget {
  Screen({
    this.hasAppBar = true,
    this.title,
    this.homeAction = true,
    this.addPadding,
    this.isRootScreen = false,
    this.autoKeyboardFocus = true
  });

  final String title;
  final bool homeAction;
  final EdgeInsets addPadding;
  final bool isRootScreen;
  final bool autoKeyboardFocus;
  final bool hasAppBar;
}

abstract class ScreenState<T extends Screen> extends State<T> {
  FocusNode _keyFocusNode = FocusNode(skipTraversal: true);
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
    return RawKeyboardListener(
      focusNode: _keyFocusNode,
      autofocus: widget.autoKeyboardFocus,
      onKey: (RawKeyEvent event) {
        if(event is RawKeyDownEvent) {
          onKeyDown(event);
        } else {
          onKeyUp(event);
        }
        // 观察到 有时正好是打断点的时候，会导致重复触发，所以在调试按键监听功能时，不要打断点
      },
      child: Scaffold(
        appBar: !widget.hasAppBar ? null : AppBar(
          title: Text(_title),
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.black87),
          textTheme: Theme.of(context).textTheme.copyWith(
            title: TextStyle(color: Colors.black87.withOpacity(0.8), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          actions: !widget.homeAction  ? null : [
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
          width: double.infinity,
          child: render(context),
        ),
      ),
    );
  }

  // 屏幕内容
  @protected
  Widget render(BuildContext context);

  @protected
  void onKeyDown(RawKeyEvent event) async {
    KeyCombination keyCombination = KeyCombination.fromRawKeyEvent(event);

    if (KeyCombination([InputKey.Enter, InputKey.OK]).isPressed(keyCombination, KeyCombinationMatchingMode.Any)) {
      onOKKeyDown();
    }

    // 如果是数字键，但不是在主界面按的，则直接返回
    // 因为其它界面才包含TextField并且有可能会在TextField上输入数字时出现冲突
    if (KeyCombination.isNumberKey(keyCombination.keys[0]) && widget.runtimeType != MainMenu) {
      return;
    }
    KeyBinding binding = KeyBindingManager.getByKeyCombination(keyCombination);
    if (binding != null) {
      onKeyBindingAction(binding.action, rootRouteReplace: !widget.isRootScreen);
    }
  }

  @protected
  void onKeyUp(RawKeyEvent event) {}

  @protected
  void onOKKeyDown() {}

  @protected
  void onKeyBindingAction(BindingAction action, {bool rootRouteReplace = false}) {
    if (getCurrentUser() == null) {
      Messager.error('未登录');
      return;
    }

    if (rootRouteReplace) {
      while (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }

    switch (action) {
      case GlobalAction.PackageCreateSmart:
        push(PackageCreateScreen(smartCreate: true));
        break;
      case GlobalAction.PackageCreate:
        push(PackageCreateScreen());
        break;
      case GlobalAction.PackageDelete:
        push(PackageDeleteScreen());
        break;
      case GlobalAction.PackageSearch:
        push(PackageSearchScreen());
        break;
      case GlobalAction.ItemAlloc:
        push(PackageItemAllocMenuScreen());
        break;
      case GlobalAction.ItemSearch:
        push(ItemSearchScreen());
        break;
    }
  }

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