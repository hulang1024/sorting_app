import 'package:flutter/material.dart';
import 'package:sorting/screens/item_alloc/item_alloc_op_type.dart';
import '../screen.dart';
import '../item/search.dart';
import '../package/create.dart';
import '../package/delete.dart';
import '../package/search.dart';

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
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.44,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        children: [
          _functionButton(
            icon: Icons.add_box,
            text: '智能建包',
            onPressed: () {
              push(PackageCreateScreen(smartCreate: true));
            },
          ),
          _functionButton(
            icon: Icons.add_box,
            text: '手动建包',
            onPressed: () {
              push(PackageCreateScreen());
            },
          ),
          _functionButton(
            icon: Icons.delete_forever,
            text: '删除集包',
            onPressed: () {
              push(PackageDeleteScreen());
            },
          ),
          _functionButton(
            icon: Icons.edit,
            text: '加包减包',
            onPressed: () {
              push(PackageItemAllocOpTypeScreen());
            },
          ),
          _functionButton(
            icon: Icons.find_in_page,
            text: '查询集包',
            onPressed: () {
              push(PackageSearchScreen());
            },
          ),
          _functionButton(
            icon: Icons.find_in_page,
            text: '查询快件',
            onPressed: () {
              push(ItemSearchScreen());
            },
          ),
        ],
      ),
    );
  }


  Widget _functionButton({
    @required IconData icon,
    @required String text,
    @required VoidCallback onPressed,
  }) {
    return RaisedButton(
      elevation: 0.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black87),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}