import 'package:flutter/material.dart';
import './product_edit.dart';
import '../models/product.dart';

class ProductListPage extends StatelessWidget {
  final List<Product> _products;
  final Function updateProduct;
  final Function deleteProduct;

  ProductListPage(this._products, this.updateProduct, this.deleteProduct);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          background: Container(color: Colors.red),
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              deleteProduct(index);
            }
          },
          key: Key(_products[index].title),
          child: Column(children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(_products[index].image),
              ),
              title: Text(_products[index].title),
              subtitle: Text('\$${_products[index].price.toString()}'),
              trailing: buileEditButton(context, index),
            ),
            Divider(),
          ]),
        );
      },
      itemCount: _products.length,
    );
  }

  Widget buileEditButton(BuildContext context, int index) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (BuildContext context) {
            return ProductEditPage(
                product: _products[index],
                updateProduct: updateProduct,
                index: index);
          }),
        );
      },
    );
  }
}
