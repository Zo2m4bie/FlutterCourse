import 'package:scoped_model/scoped_model.dart';
import './connected_products.dart';
import '../models/user.dart';

mixin UserModel on ConnectedProducts {

  void login(String email, String password) {
    authUser = User(id: 'sdfsdfsdf', email: email, password: password);
  }

}