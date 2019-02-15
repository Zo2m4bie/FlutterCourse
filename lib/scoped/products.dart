import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';

class ProductsModel extends Model{

  List<Product> _products = [];

  List<Product> get products {
    return List.from(_products);
  }

  void addProduct(Product product) {
    _products.add(product);
    print(_products);
  }

  void updateProduct(int index, Product product) {
    _products[index] = product;
  }
  void deleteProduct(int index) {
    _products.removeAt(index);
  }
}