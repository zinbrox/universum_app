import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:universum_app/helpers/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:ui' as ui;

class MarkerPoints {
  double latitude, longitude;
  MarkerPoints({this.latitude, this.longitude});
}

class ISSPage extends StatefulWidget {
  @override
  _ISSPageState createState() => _ISSPageState();
}

class _ISSPageState extends State<ISSPage> {

  // TODO: Add _interstitialAd
  InterstitialAd _interstitialAd;

  // TODO: Add _isInterstitialAdReady
  bool _isInterstitialAdReady = false;

  String message;
  int timestamp;
  String ISSLocLat="", ISSLocLong="";
  int numAstronauts;
  List<String> astronautNames = [], astronautSpacecraft = [];

  bool _mapLoading = true;

  GoogleMapController mapController;
  LatLng _center;
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polyline={};
  List<LatLng> latlng = [];

  var streamSubscription;

  var addressName = "", addressLine = "";

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
      _markers.clear();
      final Uint8List markerIcon = await getBytesFromAsset('assets/ISS.bmp', 150);
      final marker = Marker(
        icon: await BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId("ID"),
        position: LatLng(13.0827, 80.2707),
        infoWindow: InfoWindow(
          title: "ISS Current Location",
          snippet: "Current Location",
        ),
      );
      setState(() {
        _markers["ISS"] = marker;
      });
  }

  /*
  // OpenNotify API
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
      //_getLocationAddress(ISSLocLat, ISSLocLong);
      setState(() {
        _mapLoading = false;
      });
    //}
  }

   */

  double latitude, longitude, altitude, velocity;
  String visibility;

  /*
  // WheretheISSAt API
  getLoocationWIS() async {
    print("In getLocationWIS");
    String url = "https://api.wheretheiss.at/v1/satellites/25544";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    latitude = jsonData['latitude'];
    longitude = jsonData['longitude'];
    altitude = jsonData['altitude'];
    velocity = jsonData['velocity'];
    visibility = jsonData['visibility'];
    _center = LatLng(latitude, longitude);
    _getLocationAddress(latitude, longitude);
    setState(() {
      _mapLoading=false;
    });

  }
   */



  _getLocationAddress(double ISSLocLat, double ISSLocLong) async
  {
    print("In _getLocationAddress");
    print(ISSLocLat);
    final coordinates = new Coordinates(ISSLocLat, ISSLocLong);
    try {
      var addresses = await Geocoder.local.findAddressesFromCoordinates(
          coordinates);
      var first = addresses.first;
      addressName = first.featureName;
      addressLine = first.addressLine;
    }
    catch(e) {
      addressName="Couldn't find Location";
      addressLine="Couldn't find Location";
    }
    //var addresses = await Geocoder.google('AIzaSyC9bO1piARTK7Q-GdSXCODscUgQkR8-WsA').findAddressesFromCoordinates(coordinates);
   //print(addressName);
    //print(addressLine);
    //print("${first.featureName} : ${first.addressLine}");
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

  bool firstIter = true;
  Stream<List<Marker>> getLocationWIS() async* {
    print("In getLocationWIS");
    final Uint8List markerIcon = await getBytesFromAsset('assets/ISS.bmp', 150);
    while(this.mounted) {
      if(firstIter) {
        firstIter = false;
        var now = DateTime.now().millisecondsSinceEpoch;
        print(now);
        String url = "https://api.wheretheiss.at/v1/satellites/25544/positions?timestamps=${now/1000 - 2400},${now/1000 - 2100},${now/1000 - 1800},${now/1000 - 1500},${now/1000 - 1200},${now/1000 - 900},${now/1000 - 750},${now/1000 - 600},${now/1000 - 300},${now/1000 - 100}&units=kilometers";

        var response = await http.get(Uri.parse(url));
        var jsonData = jsonDecode(response.body);
        for(var elements in jsonData) {
          latitude = elements['latitude'];
          longitude = elements['longitude'];
          latlng.add(LatLng(latitude, longitude));
        }
      }
      else
        await Future.delayed(Duration(seconds: 1));
      String url = "https://api.wheretheiss.at/v1/satellites/25544";
      var response = await http.get(Uri.parse(url));
      var jsonData = jsonDecode(response.body);
      latitude = jsonData['latitude'];
      longitude = jsonData['longitude'];
      altitude = jsonData['altitude'];
      velocity = jsonData['velocity'];
      visibility = jsonData['visibility'];
      _getLocationAddress(latitude, longitude);
      //print(latitude);
      //print(longitude);

      //_markers.clear();
      final marker = Marker(
        icon: BitmapDescriptor.fromBytes(markerIcon),
        markerId: MarkerId("ID"),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: "ISS Current Location",
          snippet: "Current Location",
        ),
      );


      latlng.add(LatLng(latitude, longitude));
      _polyline.add(Polyline(
        polylineId: PolylineId("PolyID"),
        visible: true,
        //latlng is List<LatLng>
        points: latlng,
        color: Colors.orange,
        width: 3,
      ));


      if(this.mounted) {
        setState(() {
          _markers["ISS"] = marker;
          _center = LatLng(latitude, longitude);
          _mapLoading = false;
        });
      }
    }

  }

  getHumansInSpace() async {
    print("In getHumansInSpace");
    astronautNames.clear();
    astronautSpacecraft.clear();
    String url = "http://api.open-notify.org/astros.json";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    var message = jsonData['message'];
    numAstronauts = jsonData['number'];
    for(var i in jsonData['people']) {
      if(i['name']!=null && i['craft']!=null) {
        astronautNames.add(i['name']);
        astronautSpacecraft.add(i['craft']);
      }
    }
    print(astronautNames);
    print(astronautSpacecraft);
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 300,
            child: Scrollbar(
              isAlwaysShown: true,
              child: ListView.builder(
                  itemCount: astronautNames.length,
                  itemBuilder: (BuildContext context, index){
                    return ListTile(
                      title: Text(astronautNames[index]),
                      trailing: Text(astronautSpacecraft[index]),
                    );
                  }),
            ),
          );
        });

  }
  /*
  void initialiseBanner() {
      _interstitialAd = InterstitialAd(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        listener: AdListener(
          onAdLoaded: (_) {
            _isInterstitialAdReady = true;
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load an interstitial ad: ${err.message}');
            _isInterstitialAdReady = false;
            ad.dispose();
          },
          onAdClosed: (_) {
            _moveToHome();
          },
        ),
      );

      _interstitialAd.load();
    });

   */


  @override
  void initState() {
    super.initState();
    //getLoocationWIS();
    streamSubscription = getLocationWIS().listen((event) {
        print(event[0]);
    });
    //initialiseBanner();

  }

  Future<void> cancelSubscription() async {
    await streamSubscription.cancel();
  }

  @override
  void dispose() {
    cancelSubscription();
    //_bannerAd.dispose();
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
                    polylines: _polyline,
                  ),


            ),
          SizedBox(height: 10,),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text("Current Location: " + addressLine),
                  Text("Altitude: " + altitude.toStringAsFixed(2) + " km"),
                  Text("Velocity: " + velocity.toStringAsFixed(2) + " km/s"),
                  Text("Visibility: $visibility"),
                  ElevatedButton(onPressed: () async {
                    getHumansInSpace();
                  }, child: Text("Who are currently on the ISS?")),
                  /*
                  _isBannerAdReady ?
                  Container(
                    alignment: Alignment.bottomCenter,
                    //height: 100,
                    //width: MediaQuery.of(context).size.width*0.4,
                    width: _bannerAd.size.width.toDouble(),
                    height: _bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd),
                  ) : Container(),
                   */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
