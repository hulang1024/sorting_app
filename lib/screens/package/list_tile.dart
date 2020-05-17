import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/entity/package_entity.dart';
import 'details.dart';
import 'status.dart';

/// 显示在列表上的集包项目。
class PackageListTile extends ListTile {
  PackageListTile(PackageEntity package, context) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(package.code,
          style: TextStyle(color: package.status == null ? Colors.black87 : packageStatus(package.status).color, fontSize: 14),
        ),
        Text(package.destAddress ?? package.destCode,
            style: TextStyle(color: Colors.black54, fontSize: 14)),
      ],
    ),
    trailing: Icon(Icons.keyboard_arrow_right),
    contentPadding: EdgeInsets.zero,
    dense: true,
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => PackageDetailsScreen(package)));
    },
  );
}
