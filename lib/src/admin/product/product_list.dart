import 'package:flutter/material.dart';
import 'package:honey_and_thyme/src/admin/admin.dart';
import 'package:honey_and_thyme/src/widgets/back_or_add_buttons.dart';

import '../../models/enums/screens.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/app_scaffold.dart';
import '../authenticate.dart';
import 'product_form.dart';
import 'package:uuid/uuid.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  static const String route = '/products';

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  Future<List<Product>> products = ProductService.fetchProducts();

  Product product = Product();
  bool editing = false;
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentScreen: ScreensEnum.admin,
      child: Authenticate(
        child: Center(
          child: SizedBox(
            width: 300,
            child: FutureBuilder(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    submitting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (editing) {
                  return ProductForm(
                    product: product,
                    onCancel: () {
                      setState(() {
                        editing = false;
                        product = Product();
                      });
                    },
                    onSave: () async {
                      setState(() {
                        submitting = true;
                      });

                      if (product.productId == null) {
                        var uuid = const Uuid();
                        product.productId = uuid.v4();
                        await ProductService.createProduct(product);
                      } else {
                        await ProductService.updateProduct(product);
                      }

                      setState(() {
                        editing = false;
                        products = ProductService.fetchProducts();
                        submitting = false;
                        product = Product();
                      });
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return BackOrAddButtons(
                        addText: 'Add Product',
                        backRoute: AdminView.route,
                        onAdd: () {
                          setState(() {
                            editing = true;
                          });
                        },
                      );
                    }
                    final product = snapshot.data![index - 1];
                    return ListTile(
                      title: Text(product.name!),
                      subtitle: Text(product.description!),
                      trailing: Text(
                        '\$${product.price.toString()}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      onTap: () {
                        setState(() {
                          editing = true;
                          this.product = product;
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
