import 'package:sorting/generated/json/base/json_convert_content.dart';
import 'package:sorting/generated/json/base/json_filed.dart';

class PackageEntity with JsonConvert<PackageEntity> {
	String code;
	String destCode;
  String destAddress;
  String createAt;
	int operator;
	int status;
	String lastUpdate;
	String deleteAt;
	int deleteOperator;
}
