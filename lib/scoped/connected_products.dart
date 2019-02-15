import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';

mixin ConnectedProducts on Model {
  List<Product> products = [];
  User authUser;
  int selectedProdcutIndex;
  
  void addProduct(String title, String description, String image, double price) {
    final Product newProduct = Product(title: title, description: description, image: image, price: price, userEmail: authUser.email, userId: authUser.id);
    products.add(newProduct);
    selectedProdcutIndex = null;
    notifyListeners();
  }

}