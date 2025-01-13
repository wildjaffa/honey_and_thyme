import 'package:honey_and_thyme/src/models/product.dart';

import '../models/bool_result.dart';
import 'api_service.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    try {
      final result = await ApiService.getRequest<Products>(
          'api/Product/list', Products.fromJson);
      return result.values as List<Product>;
    } catch (e) {
      return [];
    }
  }

  static Future<Product> fetchProduct(String id) async {
    final result = await ApiService.getRequest<Product>(
        'api/Product/$id', Product.fromJson);
    return result;
  }

  static Future<Product> createProduct(Product product) async {
    final result = await ApiService.postRequest<Product>(
        'api/Product/create', Product.fromJson, product.toJson());
    return result;
  }

  static Future<Product> updateProduct(Product product) async {
    final result = await ApiService.postRequest<Product>(
        'api/Product/update', Product.fromJson, product.toJson());
    return result;
  }

  static Future<void> deleteProduct(String id) async {
    await ApiService.deleteRequest('api/Product/$id', BoolResult.fromJson);
  }
}
