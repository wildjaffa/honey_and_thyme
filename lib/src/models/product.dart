import 'parsable.dart';

class Products implements Parsable {
  String? id;
  List<Product?>? values;

  Products({this.id, this.values});

  Products.fromJson(Map<String, dynamic> json) {
    id = json['\$id'];
    if (json['\$values'] != null) {
      values = <Product>[];
      json['\$values'].forEach((v) {
        values!.add(Product.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$id'] = id;
    data['\$values'] = values?.map((v) => v?.toJson()).toList();
    return data;
  }
}

class Product implements Parsable {
  String? productId;
  String? name;
  String? description;
  double? price;
  double? deposit;

  Product({
    this.productId,
    this.name,
    this.description,
    this.price,
    this.deposit,
  }) {
    price ??= 0.0;
    deposit ??= 0.0;
  }

  Product.fromJson(dynamic json) {
    productId = json['ProductId'];
    name = json['Name'];
    description = json['Description'];
    price = json['Price'];
    deposit = json['Deposit'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['\$id'] = id;
    data['ProductId'] = productId;
    data['Name'] = name;
    data['Description'] = description;
    data['Price'] = price;
    data['Deposit'] = deposit;
    return data;
  }
}
