import 'package:sorting/entity/item_entity.dart';

itemEntityFromJson(ItemEntity data, Map<String, dynamic> json) {
	if (json['code'] != null) {
		data.code = json['code']?.toString();
	}
	if (json['destCode'] != null) {
		data.destCode = json['destCode']?.toString();
	}
  if (json['destAddress'] != null) {
    data.destAddress = json['destAddress']?.toString();
  }
	if (json['createAt'] != null) {
		data.createAt = json['createAt']?.toString();
	}
	if (json['packTime'] != null) {
		data.packTime = json['packTime']?.toString();
	}
  if (json['status'] != null) {
    data.status = json['status']?.toInt();
  }
	return data;
}

Map<String, dynamic> itemEntityToJson(ItemEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['code'] = entity.code;
	data['destCode'] = entity.destCode;
  data['destAddress'] = entity.destAddress;
	data['createAt'] = entity.createAt;
	data['packTime'] = entity.packTime;
	data['status'] = entity.status;
	return data;
}