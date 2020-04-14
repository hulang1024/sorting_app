import 'package:sorting/generated/json/base/json_convert_content.dart';

class ItemEntity with JsonConvert<ItemEntity> {
	String code;
	String destCode;
	String destAddress;
	String createAt;
	String packTime;
	int status;
}
