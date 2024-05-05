class BoolResult {
  bool? result;

  BoolResult({this.result});

  BoolResult.fromJson(dynamic json) {
    result = json['Result'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Result'] = result;
    return data;
  }
}
