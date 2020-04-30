import 'package:sorting/generated/json/base/json_convert_content.dart';

class PackageEntity with JsonConvert<PackageEntity> {
	String code;
	String destCode;
  String destAddress;
  String createAt;
	int operator;
  int isSmartCreate;
  int status;
	String lastUpdate;
}
