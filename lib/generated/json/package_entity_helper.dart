import 'package:sorting/entity/package_entity.dart';

packageEntityFromJson(PackageEntity data, Map<String, dynamic> json) {
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
	if (json['operator'] != null) {
		data.operator = json['operator']?.toInt();
	}
	if (json['status'] != null) {
		data.status = json['status']?.toInt();
	}
	if (json['lastUpdate'] != null) {
		data.lastUpdate = json['lastUpdate']?.toString();
	}
	if (json['deleteAt'] != null) {
		data.deleteAt = json['deleteAt']?.toString();
	}
	if (json['deleteOperator'] != null) {
		data.deleteOperator = json['deleteOperator']?.toInt();
	}
	return data;
}

Map<String, dynamic> packageEntityToJson(PackageEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['code'] = entity.code;
	data['destCode'] = entity.destCode;
	data['destAddress'] = entity.destAddress;
	data['createAt'] = entity.createAt;
	data['operator'] = entity.operator;
	data['status'] = entity.status;
	data['lastUpdate'] = entity.lastUpdate;
	data['deleteAt'] = entity.deleteAt;
	data['deleteOperator'] = entity.deleteOperator;
	return data;
}