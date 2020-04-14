import 'package:sorting/entity/package_item_op_entity.dart';

packageItemOpEntityFromJson(PackageItemOpEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id']?.toInt();
	}
	if (json['packageCode'] != null) {
		data.packageCode = json['packageCode']?.toString();
	}
	if (json['itemCode'] != null) {
		data.itemCode = json['itemCode']?.toString();
	}
	if (json['opType'] != null) {
		data.opType = json['opType']?.toInt();
	}
	if (json['opTime'] != null) {
		data.opTime = json['opTime']?.toString();
	}
	if (json['operator'] != null) {
		data.operator = json['operator']?.toInt();
	}
  if (json['status'] != null) {
    data.status = json['status']?.toInt();
  }
	if (json['operatorName'] != null) {
		data.operatorName = json['operatorName']?.toString();
	}
	if (json['operatorPhone'] != null) {
		data.operatorPhone = json['operatorPhone']?.toString();
	}
	return data;
}

Map<String, dynamic> packageItemOpEntityToJson(PackageItemOpEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['packageCode'] = entity.packageCode;
	data['itemCode'] = entity.itemCode;
	data['opType'] = entity.opType;
	data['opTime'] = entity.opTime;
	data['operator'] = entity.operator;
	data['status'] = entity.status;
	return data;
}