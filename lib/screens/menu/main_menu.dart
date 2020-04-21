import 'package:flutter/material.dart';
import 'package:sorting/screens/item_alloc/item_alloc_op_type.dart';
import '../screen.dart';
import '../item/search.dart';
import '../package/create.dart';
import '../package/delete.dart';
import '../package/search.dart';

class MainMenu extends Screen {
  MainMenu() : super(title: '首页', homeAction: false);

  @override
  State<StatefulWidget> createState() => MainMenuState();
}

class MainMenuState extends ScreenState<MainMenu> {
  @override
  Widget render(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.43,
        children: [
          _functionButton(
            icon: Icons.add_box,
            color: Colors.blueAccent,
            text: '智能建包',
            context: context,
            onPressed: () {
              push(PackageCreateScreen(smartCreate: true));
            },
          ),
          _functionButton(
            icon: Icons.add_box,
            color: Colors.blueAccent,
            text: '手动建包',
            context: context,
            onPressed: () {
              push(PackageCreateScreen());
            },
          ),
          _functionButton(
            icon: Icons.delete_forever,
            color: Colors.redAccent,
            text: '删除集包',
            context: context,
            onPressed: () {
              push(PackageDeleteScreen());
            },
          ),
          _functionButton(
            icon: Icons.edit,
            color: Colors.orangeAccent,
            text: '加包减包',
            context: context,
            onPressed: () {
              push(PackageItemAllocOpTypeScreen());
            },
          ),
          _functionButton(
            icon: Icons.find_in_page,
            color: Colors.green,
            text: '查询集包',
            context: context,
            onPressed: () {
              push(PackageSearchScreen());
            },
          ),
          _functionButton(
            icon: Icons.find_in_page,
            color: Colors.green,
            text: '查询快件',
            context: context,
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
    @required Color color,
    @required String text,
    @required BuildContext context,
    @required VoidCallback onPressed,
  }) {
    return Card(
      margin: EdgeInsets.all(2),
      elevation: 2,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            Padding(padding: EdgeInsets.symmetric(vertical: 4),),
            Text(text, style: TextStyle(fontSize: 14.5, color: Colors.white.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }
}