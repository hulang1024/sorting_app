import 'package:flutter/material.dart';
import '../screen.dart';
import '../item/search.dart';
import '../package/create.dart';
import '../package/delete.dart';
import '../package/search.dart';
import '../package_item/item_alloc.dart';

class MainMenu extends Screen {
  MainMenu() : super(title: '首页', homeAction: false, addPadding: EdgeInsets.all(-8));

  @override
  State<StatefulWidget> createState() => MainMenuState();
}

class MainMenuState extends ScreenState<MainMenu> {
  @override
  Widget render(BuildContext context) {
    return Container(
      color: Color.fromRGBO(210, 210, 210, 0.4),
      padding: EdgeInsets.all(8),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.44,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        children: [
          functionItem(
            text: '查询包裹',
            onPressed: () {
              push(PackageSearchScreen());
            },
          ),
          functionItem(
            text: '查询快件',
            onPressed: () {
              push(ItemSearchScreen());
            },
          ),
          functionItem(
            text: '智能建包',
            onPressed: () {
              push(PackageCreateScreen(smartCreate: true));
            },
          ),
          functionItem(
            text: '创建包裹',
            onPressed: () {
              push(PackageCreateScreen());
            },
          ),
          functionItem(
            text: '删除包裹',
            onPressed: () {
              push(PackageDeleteScreen());
            },
          ),
          functionItem(
            text: '加减快件',
            onPressed: () {
              push(PackageItemAllocScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget functionItem({text, onPressed}) {
    return Container(
      child: RaisedButton(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
