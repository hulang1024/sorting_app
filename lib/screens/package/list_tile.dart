import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sorting/entity/package_entity.dart';
import 'package:sorting/widgets/status.dart';
import 'details.dart';

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
Status packageStatus(code) => [
  Status(text: '创建成功', color: Colors.black87),
  Status(text: '未上传到服务器', color: Colors.orange),
  Status(text: '创建上传失败，已存在相同编号', color: Colors.red),
  Status(text: '创建上传失败，未查询到目的地编号', color: Colors.red),
  Status(text: '已删除', color: Colors.red),
][code];
