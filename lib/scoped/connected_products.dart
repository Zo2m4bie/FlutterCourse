import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin ConnectedProductsModel on Model {
  List<Product> _products = [];
  User _authUser;
  String _selectedProdcutId;
  bool _isLoading = false;
  String API_KEY = "";
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  int get selectedProductIndex {
    return _products
        .indexWhere((Product product) => product.id == _selectedProdcutId);
  }

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'http://www.nogarlicnoonions.com/images/uploads/NEWS/Chocolate.jpg',
      'price': price,
      'userEmail': _authUser.email,
      'userId': _authUser.id
    };
    try {
      final http.Response response = await http.post(
          'https://test-d9e23.firebaseio.com/products.json?auth=${_authUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: _authUser.email,
          userId: _authUser.id);
      _products.add(newProduct);
      _selectedProdcutId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(
          _products.where((Product product) => product.isFavorite));
    } else {
      return List.from(_products);
    }
  }

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'price': price,
      'image':
          'http://www.nogarlicnoonions.com/images/uploads/NEWS/Chocolate.jpg',
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.id
    };
    _isLoading = true;
    notifyListeners();
    return http
        .put(
            'https://test-d9e23.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authUser.token}',
            body: json.encode(updateData))
        .then((http.Response response) {
      _isLoading = false;
      final Product newProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = newProduct;
      notifyListeners();
      return true;
    }).catchError(() {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deleteProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    return http
        .delete(
            'https://test-d9e23.firebaseio.com/products/${deleteProductId}.json?auth=${_authUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError(() {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  String get selectedProdcutId {
    return _selectedProdcutId;
  }

  void selectProduct(String productId) {
    _selectedProdcutId = productId;
    if (_selectedProdcutId != null) {
      notifyListeners();
    }
  }

  Future<Null> fetchProduct() {
    _isLoading = true;
    notifyListeners();
    return http
        .get('https://test-d9e23.firebaseio.com/products.json?auth=${_authUser.token}')
        .then((http.Response response) {
      Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      final List<Product> fetchedProductList = [];
      productListData.forEach((String key, dynamic productData) {
        final Product newProduct = Product(
            id: key,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId']);
        fetchedProductList.add(newProduct);
      });
      _products = fetchedProductList;
      _isLoading = false;
      notifyListeners();
    });
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = _products[selectedProductIndex].isFavorite;
    final bool newFavoriteState = !isCurrentlyFavorite;
    final Product updateProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavorite: newFavoriteState,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    _products[selectedProductIndex] = updateProduct;
    notifyListeners();
  }

  Product get selectedProduct {
    if (_selectedProdcutId == null) {
      return null;
    }
    return _products
        .firstWhere((Product product) => product.id == _selectedProdcutId);
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  bool get displayFavoriteOnly => _showFavorites;
}

mixin UserModel on ConnectedProductsModel {
  
  Timer _authTimer;

  User get user {
    return _authUser;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };
    String requestUrl = mode == AuthMode.Login
        ? "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${API_KEY}"
        : "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=${API_KEY}";
    ;
    final http.Response response = await http.post(requestUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(authData));

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong!';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      _authUser = User(id: responseData['localId'], email: email, token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      final DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
      message = 'Authentication succeeded!';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found!';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid!';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This mail already exists!';
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAutenticate() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token');
      final String expiryTimeString = prefs.getString('expiryTime');
      if(token != null) {
        final DateTime now = DateTime.now();
        final DateTime parsedExpirityTime = DateTime.parse(expiryTimeString);
        if(parsedExpirityTime.isBefore(now)){
           _authUser = null;
           notifyListeners();
          return;
        }

        final String userEmail = prefs.getString('userEmail');
        final String userId = prefs.getString('userId');
        final tokenLifespan = parsedExpirityTime.difference(now).inSeconds;
        _authUser = User(id: userId, email: userEmail, token: token);
        setAuthTimeout(tokenLifespan);
        notifyListeners();
      }
  }
  
  void logout() async {
    _authTimer.cancel();
    _authUser = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    prefs.remove('expiryTime');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), () {
      logout();
    });
  }
}

mixin UtilityMode on ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
