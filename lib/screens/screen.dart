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
import 'item_alloc/item_alloc.dart';
import 'item_alloc/item_alloc_menu.dart';
import 'item_alloc/search.dart';
import 'menu/main_menu.dart';
import 'package/create.dart';
import 'package/delete.dart';
import 'package/search.dart';

/// 屏幕（页面）抽象类。
///
/// 其它类继承该类，可复用一些代码，比如 可以获得一致的外观、键盘监听、路由方法的封装等。
abstract class Screen extends StatefulWidget {
  Screen({
    Key key,
    this.hasAppBar = true,
    this.title,
    this.homeAction = true,
    this.addPadding,
    this.isNavigationScreen = false,
    this.autoKeyboardFocus = true
  }) : super(key: key);

  /// 在应用程序栏显示的标题。
  final String title;

  /// 是否在程序栏上显示 返回主页 的图标按钮，用以快速返回主页。
  final bool homeAction;

  /// 增加边距。
  ///
  /// Screen有一个默认内边距，如果这个属性不为空，则会加上该属性的值，
  /// 如果你不想让一个Screen有内边距，可以设置值如[EdgeInsets.add(-8)]，
  /// 为了外观一致性，尽量不要设置该属性。
  final EdgeInsets addPadding;

  /// 是否是导航屏幕。
  final bool isNavigationScreen;

  /// 设置键盘焦点
  ///
  /// 默认值为true，该属性会去设置Screen内部[RawKeyboardListener]的[autofocus]属性。
  /// 在一些表单Screen需要设置TextField的焦点，但由于[RawKeyboardListener]的[autofocus]也为true，
  /// TextField的焦点将会失效，除非将此属性设置为false（键盘监听依旧可用）
  /// 注意在其它Screen里使用 `FocusScope.of(context).unfocus()` 会导致所有Screen里的[RawKeyboardListener]也失去焦点，
  /// 应使用 FocusScope.of(context).unfocus(focusPrevious: true)
  final bool autoKeyboardFocus;

  /// 是否有应用程序栏。
  final bool hasAppBar;
}

abstract class ScreenState<T extends Screen> extends State<T> {
  FocusNode keyFocusNode = FocusNode(skipTraversal: true);
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
      focusNode: keyFocusNode,
      autofocus: widget.autoKeyboardFocus,
      onKey: (RawKeyEvent event) {
        KeyCombination keyCombination = KeyCombination.fromRawKeyEvent(event);
        if(event is RawKeyDownEvent) {
          onKeyDown(keyCombination);
        } else {
          onKeyUp(keyCombination);
        }
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

  /// 屏幕内容
  @protected
  Widget render(BuildContext context);

  @protected
  void onKeyDown(KeyCombination keyCombination) async {
    // 判断是否按下了OK键
    if (KeyCombination([InputKey.Enter, InputKey.OK]).isPressed(keyCombination)) {
      onOKKeyDown();
      // 如果不是主菜单界面按的OK，结束流程
      if (widget.runtimeType != MainMenu) {
        return;
      }
    } else {
      // 如果是正在文本输入，结束流程
      if (FocusScope.of(context).focusedChild.hasFocus &&
          FocusScope.of(context).focusedChild.context.widget.runtimeType == EditableText) {
        return;
      }
    }

    // 查询按键的按键绑定
    KeyBinding binding = KeyBindingManager.getByKeyCombination(keyCombination);
    if (binding != null) {
      onKeyBindingAction(binding.action, rootRouteReplace: !widget.isNavigationScreen);
    }
  }

  @protected
  void onKeyUp(KeyCombination keyCombination) {}

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
      case GlobalAction.ItemAllocDelete:
        push(PackageItemAllocScreen(opType: 2));
        break;
      case GlobalAction.ItemAllocAdd:
        push(PackageItemAllocScreen(opType: 1));
        break;
      case GlobalAction.ItemAllocSearch:
        push(PackageItemAllocSearchScreen());
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