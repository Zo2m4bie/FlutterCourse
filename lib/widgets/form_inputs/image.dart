import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Product product;
  
  ImageInput(this.setImage, this.product);

  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;

  void _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      setState(() {
        _imageFile = image;
      });
      widget.setImage(image);
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Use camera'),
                  onPressed: () => _getImage(context, ImageSource.camera),
                ),
                SizedBox(height: 5.0),
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text('Use gallery'),
                  onPressed: () => _getImage(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).accentColor;
    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(color: buttonColor, width: 2.0),
          onPressed: () => _openImagePicker(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: buttonColor,
              ),
              SizedBox(width: 5.0),
              Text(
                'Add image',
                style: TextStyle(color: buttonColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        _imageFile == null
            ? Text('Please pick an image')
            : Image.file(
                _imageFile,
                fit: BoxFit.cover,
                height: 300.0,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topCenter,
              ),
      ],
    );
  }
}
