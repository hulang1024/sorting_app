import 'package:flutter/material.dart';
import 'package:sorting/input/bindings/inputkey.dart';
import 'package:sorting/input/bindings/key_bindings_manager.dart';
import 'package:sorting/input/bindings/action.dart';
import '../screen.dart';

class MainMenu extends Screen {
  MainMenu() : super(title: '首页', homeAction: false, isRootScreen: true);

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
          childAspectRatio: 1.41,
          children: [
            _functionCard(
              action: GlobalAction.PackageCreateSmart,
              icon: Icons.add_box,
              color: Colors.blueAccent,
              text: '智能建包',
            ),
            _functionCard(
              action: GlobalAction.PackageCreate,
              icon: Icons.add_box,
              color: Colors.blueAccent,
              text: '手动建包',
            ),
            _functionCard(
              action: GlobalAction.PackageDelete,
              icon: Icons.delete_forever,
              color: Colors.redAccent,
              text: '删除集包',
            ),
            _functionCard(
              action: GlobalAction.ItemAlloc,
              icon: Icons.edit,
              color: Colors.orangeAccent,
              text: '加包减包',
            ),
            _functionCard(
              action: GlobalAction.PackageSearch,
              icon: Icons.find_in_page,
              color: Colors.green,
              text: '查询集包',
            ),
            _functionCard(
              action: GlobalAction.ItemSearch,
              icon: Icons.search,
              color: Colors.green,
              text: '查询快件',
            ),
          ],
        ),
    );
  }

  Widget _functionCard({
    @required GlobalAction action,
    @required IconData icon,
    @required Color color,
    @required String text,
  }) {
    String keysText = KeyBindingManager.getByAction(action)
        .where((binding) => binding.keyCombination.keys[0] != InputKey.None)
        .map((binding) => binding.keyCombination.readableString())
        .join(' / ');
    return Card(
      margin: EdgeInsets.all(2),
      elevation: 1.5,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      child: InkWell(
        focusNode: FocusNode(skipTraversal: true),
        onTap: () {
          onKeyBindingAction(action);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: Colors.white, size: 34),
            Text(text, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
            Text(keysText,
              style: TextStyle(fontSize: 11, color: Colors.white38),),
          ],
        ),
      ),
    );
  }
}