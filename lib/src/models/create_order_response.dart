class CreateOrderResponse {
  String? orderId;

  CreateOrderResponse({this.orderId});

  CreateOrderResponse.fromJson(dynamic json) {
    orderId = json['OrderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['OrderId'] = orderId;
    return data;
  }
}
