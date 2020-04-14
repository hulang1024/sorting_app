import 'package:sorting/generated/json/base/json_convert_content.dart';

class UserEntity with JsonConvert<UserEntity> {
	int id;
	String code;
	String branchCode;
	String name;
	String phone;
	String password;
	String createAt;
}
