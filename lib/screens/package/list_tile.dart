import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'details.dart';

class PackageListTile extends ListTile {
  PackageListTile(package, context) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(package['code'],
          style: TextStyle(color: package['status'] == null ? Colors.black87 : statusColor(package['status']), fontSize: 14),
        ),
        Text(package['destAddress'] ?? package['destCode'],
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

Color statusColor(status) => [Colors.black87, Colors.orange, Colors.red, Colors.red][status];