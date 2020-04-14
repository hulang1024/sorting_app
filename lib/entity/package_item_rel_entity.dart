import 'package:sorting/generated/json/base/json_convert_content.dart';

class PackageItemRelEntity with JsonConvert<PackageItemRelEntity> {
	int id;
	String packageCode;
	String itemCode;
	String createAt;
	int operator;
	int status;
}
