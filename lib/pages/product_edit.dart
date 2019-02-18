import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped/main.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? "" : product.title,
      decoration: InputDecoration(labelText: 'Product Title'),
      validator: (String value) {
        if (value.isEmpty || value.trim().length < 5) {
          return 'Title is required and should be at least 5 character!';
        }
      },
      onSaved: (String value) => _formData['title'] = value,
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? "" : product.description,
      maxLines: 4,
      decoration: InputDecoration(labelText: 'Product Description'),
      validator: (String value) {
        if (value.isEmpty || value.trim().length < 10) {
          return 'Description is required and should be at least 10 character!';
        }
      },
      onSaved: (String value) => _formData['description'] = value,
    );
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? "" : product.price.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: 'Product Price'),
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be number!';
        }
      },
      onSaved: (String value) => _formData['price'] = double.parse(value),
    );
  }

  void _submitForm(Function addProduct, Function updateProduct, Function setSelectedProduct,
      [String selectedProductId]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductId == null) {
      addProduct(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        _formData['price'])
        .then((bool isSuccess) {
           if(!isSuccess) {
             showDialog(context: context, 
              builder: (BuildContext context) {
               return AlertDialog(
                  title: Text("Something went wrong"), 
                  content: Text('Try again later'), 
                  actions: <Widget>[
                    FlatButton(onPressed: () => Navigator.of(context).pop(),
                    child: Text('Ok')),
                  ],);
              });
           } else {
             Navigator.pushReplacementNamed(context, '/products').then((_) => setSelectedProduct(null));
           }
         });
    } else {
      updateProduct(
        _formData['title'],
        _formData['description'],
        _formData['image'],
        _formData['price'])
        .then((_) => Navigator.pushReplacementNamed(context, '/products').then((_) => setSelectedProduct(null)));
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      Widget pageContent = buildPageContent(context, model.selectedProduct);
      return model.selectedProdcutId == null
          ? pageContent
          : Scaffold(
              appBar: AppBar(title: Text('Edit product')), body: pageContent);
    });
  }

  GestureDetector buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding / 2),
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(
                height: 10.0,
              ),
              buildSubmitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          if(model.isLoading){
            return Center(child: CircularProgressIndicator());
          } else {
              return RaisedButton(
                child: Text('Save'),
                textColor: Colors.white,
                onPressed: () => _submitForm(model.addProduct,
                    model.updateProduct,model.selectProduct, model.selectedProdcutId),
              );
          }
        });
  }
}
