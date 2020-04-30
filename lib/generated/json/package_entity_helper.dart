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
  if (json['isSmartCreate'] != null) {
    data.isSmartCreate = json['isSmartCreate']?.toInt();
  }
	if (json['status'] != null) {
		data.status = json['status']?.toInt();
	}
	if (json['lastUpdate'] != null) {
		data.lastUpdate = json['lastUpdate']?.toString();
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
  data['isSmartCreate'] = entity.isSmartCreate;
  data['status'] = entity.status;
	data['lastUpdate'] = entity.lastUpdate;
	return data;
}