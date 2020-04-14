part of api;

class Result {
  int _code;
  String _msg;
  Map _data;

  get code => _code;
  get msg => _msg;
  Map get data => _data;
  get isOk => _code == 0;

  Result();

  Result.ok() {
    _code = 0;
  }

  Result.fail({code, msg}) {
    _code = code ?? 1;
    if (msg != null)
      _msg = msg;
  }

  Result.from([bool ok]) {
    _code = ok ? 0 : 1;
  }

  static fromMap(Map<String, dynamic> map) {
    Result result = Result();
    result._code = map['code'];
    result._msg = map['msg'];
    result._data = map['data'];
    return result;
  }
}