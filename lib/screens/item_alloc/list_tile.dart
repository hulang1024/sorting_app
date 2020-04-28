import 'package:flutter/material.dart';
import 'package:sorting/entity/package_item_op_entity.dart';
import 'package:sorting/widgets/status.dart';

import 'details.dart';

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

Status itemAllocStatus(code) => [
  Status(text: '已上传成功', color: Colors.green),
  Status(text: '未上传到服务器', color: Colors.orange),
  Status(text: '快件编号有误', color: Colors.red),
  Status(text: '不存在快件', color: Colors.red),
  Status(text: '快件早已加到其它集包', color: Colors.red),
  Status(text: '不存在集包', color: Colors.red),
  Status(text: '快件和集包的目的地编号不相同', color: Colors.red),
][code];