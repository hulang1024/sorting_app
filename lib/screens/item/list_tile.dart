import 'package:flutter/material.dart';
import 'package:sorting/entity/item_entity.dart';
import 'package:sorting/widgets/message.dart';
import 'package:sorting/widgets/status.dart';
import 'details.dart';

class ItemListTile extends ListTile {
  ItemListTile(ItemEntity item, verbose, context) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(item.code,
          style: verbose
              ? TextStyle(color: itemAllocStatus(item.packTime != null).color, fontSize: 14)
              : null,
        ),
        if (item.status != null)
          Text(itemStatus(item.status).text,
            style: TextStyle(color: itemStatus(item.status).color, fontSize: 12),
          ),
        if (verbose && item.destAddress != null)
          Text(item.destAddress, style: TextStyle(fontSize: 14)),
      ],
    ),
    trailing: Icon(Icons.keyboard_arrow_right),
    contentPadding: EdgeInsets.zero,
    dense: true,
    onTap: () {
      if (item.status == null || item.status == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsScreen(item)));
      } else {
        Messager.warning('未上传成功,无法查询详情');
      }
    },
  );
}

Status itemStatus(code) => [
  Status(text: '已上传成功', color: Colors.black87),
  Status(text: '未上传到服务器', color: Colors.orange),
  Status(text: '快件编号有误', color: Colors.red),
  Status(text: '不存在快件', color: Colors.red),
  Status(text: '快件早已加到其它集包', color: Colors.red),
  Status(text: '快件和集包的目的地编号不相同', color: Colors.red),
][code];
Status itemAllocStatus(alreadyAlloc) => alreadyAlloc
  ? Status(text: '已分配', color: Colors.green)
  : Status(text: '未分配', color: Colors.grey);
