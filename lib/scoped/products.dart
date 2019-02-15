import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import './connected_products.dart';

mixin ProductsModel on ConnectedProducts {
  bool _showFavorites = false;

  List<Product> get allProducts {
    return List.from(products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(products.where((Product product) => product.isFavorite));
    } else {
      return List.from(products);
    }
  }

  void updateProduct(
      String title, String description, String image, double price) {
    final Product newProduct = Product(
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: products[selectedProdcutIndex].userEmail,
        userId: products[selectedProdcutIndex].userId);
    products[selectedProdcutIndex] = newProduct;
    selectedProdcutIndex = null;
    notifyListeners();
  }

  void deleteProduct(int index) {
    products.removeAt(selectedProdcutIndex);
    selectedProdcutIndex = null;
    notifyListeners();
  }

  int get selProdcutIndex {
    return selectedProdcutIndex;
  }

  void selectproduct(int index) {
    selectedProdcutIndex = index;
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = products[selectedProdcutIndex].isFavorite;
    final bool newFavoriteState = !isCurrentlyFavorite;
    final Product updateProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavorite: newFavoriteState);
    products[selectedProdcutIndex] = updateProduct;
    selectedProdcutIndex = null;
    notifyListeners();
    selectedProdcutIndex = null;
  }

  Product get selectedProduct {
    if (selectedProdcutIndex == null) {
      return null;
    }
    return products[selectedProdcutIndex];
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  bool get displayFavoriteOnly => _showFavorites;
}
