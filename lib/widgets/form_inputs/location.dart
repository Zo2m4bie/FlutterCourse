import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:map_view/map_view.dart';
import 'package:location/location.dart' as geoloc;
import 'package:http/http.dart' as http;
import '../helpers/ensure_visible.dart';
import '../../models/location_data.dart';
import '../../models/product.dart';

class LocationInput extends StatefulWidget {
  final String MAP_API_KEY = '';
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addresInputFocusNode = FocusNode();
  Uri _staticMapUri;
  final TextEditingController _textEditingController = TextEditingController();
  LocationData _locationData;

  @override
  void initState() {
    _addresInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _getStaticMap(widget.product.location.address, geocode: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addresInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _updateLocation() {
    if (!_addresInputFocusNode.hasFocus) {
      _getStaticMap(_textEditingController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addresInputFocusNode,
          child: TextFormField(
              controller: _textEditingController,
              decoration: InputDecoration(labelText: 'Address'),
              focusNode: _addresInputFocusNode,
              validator: (String value) {
                if (_locationData == null || value.isEmpty) {
                  return 'No valid location found.';
                }
              }),
        ),
        SizedBox(height: 10.0),
        FlatButton(
          child: Text('Locate User'),
          onPressed: _getUserLocation,
        ),
        SizedBox(height: 10.0),
        _staticMapUri == null
            ? Container()
            : Image.network(_staticMapUri.toString())
      ],
    );
  }

  Future<String> _getAddress(double lat, double lng) async {
    Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
          'latlng': '${lat.toString()},${lng.toString()}',
          'key': widget.MAP_API_KEY
      });
     print(uri.toString());
    // final http.Response response = await http.get(uri);
    //  print("lat = ${lat.toString()} lng = ${lng.toString()}");
    //  print(response.body);
    // final decodedResponse = json.decode(response.body);
    final formattedAddress = 'Test address';//decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  void _getUserLocation() async {
    final location = geoloc.Location();
    final currentLocation = await location.getLocation();
    print(currentLocation);
    final address = await _getAddress(currentLocation['latitude'], currentLocation['longitude']);
    print(address);
    _getStaticMap(address, geocode: false, lat: currentLocation['latitude'], lng: currentLocation['longitude']);
  }

  void _getStaticMap(String address, {bool geocode = true, double lat, double lng}) async {
    if (address.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https(
          'maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': widget.MAP_API_KEY
      });
      final http.Response response = await http.get(uri);
      print(response.statusCode);
      print(response.body);
      final decodedResponse = json.decode(response.body);
      final formatedAddress = decodedResponse['result'][0]['formatted_address'];
      final coordinates = decodedResponse['result'][0]['geometry']['location'];
      _locationData = LocationData(
          address: 'Test address',//formatedAddress,
          latitude: 37.4219983,//coordinates['lat'],
          longitude: -122.084);//coordinates['lng']);
    } else if(lat == null && lng == null) {
      _locationData = widget.product.location;
    } else {
      _locationData = LocationData(latitude: lat, longitude: lng, address: address);
    }

    final StaticMapProvider staticMapProvider =
        StaticMapProvider(widget.MAP_API_KEY);
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker('Position', 'Position 2', _locationData.latitude,
          _locationData.longitude)
    ],
        center: Location(_locationData.latitude, _locationData.longitude),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);

    widget.setLocation(_locationData);
    if(mounted){
      setState(() {
        _textEditingController.text = _locationData.address;
        _staticMapUri = staticMapUri;
      });
    }
  }
}
