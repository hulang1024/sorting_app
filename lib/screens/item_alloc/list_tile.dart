import 'package:flutter/material.dart';
import 'package:sorting/entity/package_item_op_entity.dart';
import 'details.dart';
import 'status.dart';

/// 显示在列表上的快件分配操作记录项目。
class ItemOpRecordListTile extends ListTile {
  ItemOpRecordListTile(PackageItemOpEntity op, context, {showType: false}) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(op.packageCode),
            Padding(padding: EdgeInsets.symmetric(vertical: 2),),
            Text(op.itemCode),
          ],
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              if (showType) Icon(
                op.opType == 1 ? Icons.add : Icons.remove,
                size: 14.5,
                color: op.opType == 1 ? Colors.blueAccent : Colors.redAccent,
              ),
              Padding(padding: EdgeInsets.only(left: 4),),
              Text(op.status == 0 ? '已成功' : op.status == 1 ? '未上传' : '已失败',
                  style: TextStyle(color: itemAllocStatus(op.status).color)),
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
