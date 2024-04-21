class BoolResult {
  bool? result;

  BoolResult({this.result});

  BoolResult.fromJson(dynamic json) {
    result = json['result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result;
    return data;
  }
}
