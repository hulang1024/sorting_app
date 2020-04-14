import 'package:sorting/entity/package_item_rel_entity.dart';

packageItemRelEntityFromJson(PackageItemRelEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id']?.toInt();
	}
	if (json['packageCode'] != null) {
		data.packageCode = json['packageCode']?.toString();
	}
	if (json['itemCode'] != null) {
		data.itemCode = json['itemCode']?.toString();
	}
	if (json['createAt'] != null) {
		data.createAt = json['createAt']?.toString();
	}
	if (json['operator'] != null) {
		data.operator = json['operator']?.toInt();
	}
  if (json['status'] != null) {
    data.status = json['status']?.toInt();
  }
	return data;
}

Map<String, dynamic> packageItemRelEntityToJson(PackageItemRelEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['packageCode'] = entity.packageCode;
	data['itemCode'] = entity.itemCode;
	data['createAt'] = entity.createAt;
	data['operator'] = entity.operator;
	data['status'] = entity.status;
	return data;
}