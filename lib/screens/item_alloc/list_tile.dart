import 'package:flutter/material.dart';
import 'package:sorting/entity/package_item_op_entity.dart';
import 'package:sorting/screens/item/list_tile.dart';

import 'details.dart';

class ItemOpRecordListTile extends ListTile {
  ItemOpRecordListTile(PackageItemOpEntity op, context, {showType: false}) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(op.packageCode),
        Text(op.itemCode),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children:[
            if (showType) Icon(
              op.opType == 1 ? Icons.add : Icons.remove,
              size: 14.5,
              color: op.opType == 1 ? Colors.blueAccent : Colors.redAccent,
            ),
            Padding(padding: EdgeInsets.only(left: 2),),
            Text(op.status == 0 ? '已成功' : op.status == 1 ? '未上传' : '已失败',
                style: TextStyle(color: itemStatus(op.status).color)),
            ]
        ),
      ],
    ),
    trailing: Icon(Icons.keyboard_arrow_right),
    contentPadding: EdgeInsets.zero,
    dense: true,
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ItemAllocOpDetailsScreen(op)));
    },
  );
}