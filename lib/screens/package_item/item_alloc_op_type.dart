import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sorting/screens/screen.dart';

import 'item_alloc.dart';

class PackageItemAllocOpTypeScreen extends Screen {
  PackageItemAllocOpTypeScreen() : super(title: '选择操作', addPadding: EdgeInsets.all(-8));

  @override
  State<StatefulWidget> createState() => _PackageItemAllocOpTypeScreenState();
}

class _PackageItemAllocOpTypeScreenState extends ScreenState<PackageItemAllocOpTypeScreen> {
  @override
  Widget render(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _TypeButton(
          icon: Icons.remove,
          color: Colors.redAccent,
          text: '减件',
          onTap: () {
            push(PackageItemAllocScreen(opType: 2));
          },
        ),
        _TypeButton(
          icon: Icons.add,
          color: Colors.blueAccent,
          text: '加件',
          onTap: () {
            push(PackageItemAllocScreen(opType: 1));
          },
        ),
      ],
    );
  }

}

class _TypeButton extends StatelessWidget {
  _TypeButton({this.icon, this.text, this.color, this.onTap});
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Center(child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: Colors.white),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}