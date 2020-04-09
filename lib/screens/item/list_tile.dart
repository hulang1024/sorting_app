import 'package:flutter/material.dart';
import 'details.dart';

class ItemListTile extends ListTile {
  ItemListTile(item, verbose, context) : super(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(item['code'],
          style: verbose
              ? TextStyle(color: allocStatusColor(item['packTime'] != null), fontSize: 14)
              : null,
        ),
        Text(item['destAddress'], style: TextStyle(fontSize: 14)),
      ],
      ),
    trailing: Icon(Icons.keyboard_arrow_right),
    contentPadding: EdgeInsets.zero,
    dense: true,
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ItemDetailsScreen(item)));
    },
  );
}

Color allocStatusColor(alreadyAlloc) => alreadyAlloc ? Colors.green : Colors.grey;
