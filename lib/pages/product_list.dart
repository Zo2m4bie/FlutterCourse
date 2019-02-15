import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './product_edit.dart';
import '../scoped/main.dart';

class ProductListPage extends StatelessWidget {
  ProductListPage();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) =>
      ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            background: Container(color: Colors.red),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                model.selectproduct(index);
                model.deleteProduct(index);
              }
            },
            key: Key(model.allProducts[index].title),
            child: Column(children: <Widget>[
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(model.allProducts[index].image),
                ),
                title: Text(model.allProducts[index].title),
                subtitle: Text('\$${model.allProducts[index].price.toString()}'),
                trailing: buileEditButton(context, index, model),
              ),
              Divider(),
            ]),
          );
        },
        itemCount: model.allProducts.length,
      )
    );
  }

  Widget buileEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                model.selectproduct(index);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return ProductEditPage();
                  }),
                );
              },
            );
  }
}
