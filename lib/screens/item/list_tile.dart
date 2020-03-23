import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../package/details.dart';
import 'details.dart';

//到
ListTile buildItemListTile(item, verbose, context) {
  return ListTile(
    title: Text(item['code']),
    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      !verbose
          ? Container()
          : RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item['packTime'] == null ? '未分配 ' : '已分配 ',
                    style: TextStyle(color: item['packTime'] == null ? Colors.grey : Colors.green),
                  ),
                ],
              ),
            ),
      Text(item['destAddress']),
    ]),
    contentPadding: EdgeInsets.fromLTRB(0, 4, 0, 4),
    trailing: Container(child: Icon(Icons.keyboard_arrow_right)),
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsScreen(item)));
    },
  );
}
