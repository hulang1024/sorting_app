import 'package:flutter/material.dart';
import 'package:sorting/entity/item_entity.dart';
import 'package:sorting/widgets/message.dart';
import 'package:sorting/widgets/status.dart';
import 'details.dart';

/// 显示在列表上的快件项目。
class ItemListTile extends ListTile {
  ItemListTile(ItemEntity item, verbose, context) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(item.code,
          style: verbose
              ? TextStyle(color: itemStatus(item.packTime != null).color, fontSize: 14)
              : null,
        ),
        if (item.status != null)
          Text(itemStatus(item.packTime != null).text,
            style: TextStyle(color: itemStatus(item.packTime != null).color, fontSize: 12),
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

Status itemStatus(alreadyAlloc) => alreadyAlloc
  ? Status(text: '已分配', color: Colors.green)
  : Status(text: '未分配', color: Colors.grey);
