import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductFAB extends StatefulWidget {
  final Product product;

  ProductFAB(this.product);

  @override
  State<StatefulWidget> createState() {
    return _ProductFABState();
  }
}

class _ProductFABState extends State<ProductFAB> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).cardColor,
            heroTag: 'contact',
            mini: true,
            onPressed: () async {
              final url = 'mailto:${widget.product.userEmail}';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch!';
              }
            },
            child: Icon(Icons.mail, color: Theme.of(context).accentColor),
          ),
        ),
        Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).cardColor,
            heroTag: 'favorite',
            mini: true,
            onPressed: () {
              model.toggleProductFavoriteStatus();
            },
            child: Icon(
                model.selectedProduct.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red),
          ),
        ),
        Container(
          child: FloatingActionButton(
            heroTag: 'options',
            onPressed: () {},
            child: Icon(Icons.more_vert),
          ),
        ),
      ]);
    });
  }
}
