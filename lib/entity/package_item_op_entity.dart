import 'package:sorting/generated/json/base/json_convert_content.dart';

class PackageItemOpEntity with JsonConvert<PackageItemOpEntity> {
	int id;
	String packageCode;
	String itemCode;
	int opType;
	String opTime;
	int operator;
	int status;
	String operatorName;
	String operatorPhone;
}
