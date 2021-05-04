import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.clear();
      final marker = Marker(
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
    while (true) {
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
      _center = LatLng(double.parse(ISSLocLat), double.parse(ISSLocLong));
      setState(() {
        _mapLoading = false;
      });
    }
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
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ISS"),
      ),
      body: _mapLoading ? Center(child: Text(ISSLocLat + " " + ISSLocLong)) :
      GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }
}
