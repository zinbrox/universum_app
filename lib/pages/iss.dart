import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;

class ISSPage extends StatefulWidget {
  @override
  _ISSPageState createState() => _ISSPageState();
}

class _ISSPageState extends State<ISSPage> {

  String message;
  int timestamp;
  String ISSLocLat="", ISSLocLong="";

  bool _mapLoading = true;

  GoogleMapController mapController;
  LatLng _center;
  final Map<String, Marker> _markers = {};

  var streamSubscription;

  var addressName = "", addressLine = "";

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() async {
      _markers.clear();
      final Uint8List markerIcon = await getBytesFromAsset('assets/ISS.bmp', 150);
      final marker = Marker(
        icon: await BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId("ID"),
        position: LatLng(double.parse(ISSLocLat), double.parse(ISSLocLong)),
        infoWindow: InfoWindow(
          title: "ISS Current Location",
          snippet: "Current Location",
        ),
      );
      _markers["ISS"] = marker;
    });
  }

  getLocation() async {
    print("In getLocation()");

    //while (true) {
      //await Future.delayed(Duration(seconds: 5));
      String url = "http://api.open-notify.org/iss-now.json?";
      var response = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(response.body);
      //print(jsonData);
      message = jsonData['message'];
      timestamp = jsonData['timestamp'];
      ISSLocLat = jsonData['iss_position']['latitude'];
      ISSLocLong = jsonData['iss_position']['longitude'];
      print(ISSLocLong);
      print(ISSLocLat);
      _center = LatLng(double.parse(ISSLocLat), double.parse(ISSLocLong));
      _getLocationAddress(ISSLocLat, ISSLocLong);
      setState(() {
        _mapLoading = false;
      });
    //}
  }

  _getLocationAddress(String ISSLocLat, String ISSLocLong) async
  {
    print("In _getLocationAddress");
    print(double.parse(ISSLocLat));
    final coordinates = new Coordinates(double.parse(ISSLocLat), double.parse(ISSLocLong));
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    addressName = first.featureName;
    addressLine = first.addressLine;
    print("${first.featureName} : ${first.addressLine}");
    setState(() {

    });
  }

  /*
  // For Continuously getting Locations every 5sec
  Stream<List<String>> getLocation() async* {
    //print("In getLocation()");
    while(true) {
      await Future.delayed(Duration(seconds: 5));
      String url = "http://api.open-notify.org/iss-now.json?";
      var response = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(response.body);
      //print(jsonData);
      message = jsonData['message'];
      timestamp = jsonData['timestamp'];
      ISSLocLat = jsonData['iss_position']['latitude'];
      ISSLocLong = jsonData['iss_position']['longitude'];
      print(ISSLocLong);
      print(ISSLocLat);

      List<String> l = [];
      l.add(ISSLocLat);
      l.add(ISSLocLong);
      yield l;
    }
  }

   */

  @override
  void initState() {
    super.initState();
    getLocation();
    /*
    streamSubscription = getLocation().listen((event) {
        print(event[0]);
    });
     */
  }

  @override
  void dispose() {
    //streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ISS"),
      ),
      body: _mapLoading ? Center(child: CircularProgressIndicator()) :
      Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.7,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 3.0,
              ),
              markers: _markers.values.toSet(),
            ),
          ),
          Text("Current Location: " + addressLine),
        ],
      ),
    );
  }
}
