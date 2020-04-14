import 'package:sorting/entity/user_entity.dart';

userEntityFromJson(UserEntity data, Map<String, dynamic> json) {
	if (json['id'] != null) {
		data.id = json['id']?.toInt();
	}
	if (json['code'] != null) {
		data.code = json['code']?.toString();
	}
	if (json['branchCode'] != null) {
		data.branchCode = json['branchCode']?.toString();
	}
	if (json['name'] != null) {
		data.name = json['name']?.toString();
	}
	if (json['phone'] != null) {
		data.phone = json['phone']?.toString();
	}
	if (json['password'] != null) {
		data.password = json['password']?.toString();
	}
	if (json['createAt'] != null) {
		data.createAt = json['createAt']?.toString();
	}
	return data;
}

Map<String, dynamic> userEntityToJson(UserEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['id'] = entity.id;
	data['code'] = entity.code;
	data['branchCode'] = entity.branchCode;
	data['name'] = entity.name;
	data['phone'] = entity.phone;
	data['password'] = entity.password;
	data['createAt'] = entity.createAt;
	return data;
}