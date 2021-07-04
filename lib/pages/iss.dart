import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:universum_app/styles/color_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkerPoints {
  double latitude, longitude;
  MarkerPoints({this.latitude, this.longitude});
}

class Reports {
  String title, url, newsSite, summary;
  DateTime date;
  Reports({this.title, this.url, this.newsSite, this.summary, this.date});

}

class ISSPage extends StatefulWidget {
  @override
  _ISSPageState createState() => _ISSPageState();
}

class _ISSPageState extends State<ISSPage> {

  String message;
  int timestamp;
  String ISSLocLat="", ISSLocLong="";
  int numAstronauts;
  List<String> astronautNames = [], astronautSpacecraft = [];

  bool _loading = true, _mapLoading=true;

  GoogleMapController mapController;
  LatLng _center;
  final Map<String, Marker> _markers = {};
  final Set<Polyline> _polyline={};
  List<LatLng> latlng = [];

  var streamSubscription;

  var addressName = "", addressLine = "";

  int statusCodeReports;
  List<Reports> reports = [];

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
      setState(() {
        _mapLoading=false;
      });
  }


  double latitude, longitude, altitude, velocity;
  String visibility;



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
  }


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
        width: 3,
        color: Colors.grey[700],
      ));


      if(this.mounted) {
        setState(() {
          _markers["ISS"] = marker;
          _center = LatLng(latitude, longitude);
          _loading = false;
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
      if(i['name']!=null && i['craft']=="ISS") {
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
            height: MediaQuery.of(context).size.height*0.6,
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

  Future<void> getReports() async {
    print("In getReports");
    Reports report;
    String url = "https://api.spaceflightnewsapi.net/v3/reports";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    statusCodeReports = response.statusCode;
    if(statusCodeReports==200) {
      if(reports.isNotEmpty)
        Navigator.push(context, MaterialPageRoute(builder: (context) => ISSReports(reports: reports)));
      else {
        for (var result in jsonData) {
          report = Reports(
            title: result['title'],
            url: result['url'],
            summary: result['summary'],
            newsSite: result['newsSite'],
            date: DateTime.parse(result['publishedAt']),
          );
          reports.add(report);
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => ISSReports(reports: reports)));
      }
    }
    else
      Fluttertoast.showToast(
          msg: "Error. Status Code: $statusCodeReports",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0
      );
  }



  @override
  void initState() {
    super.initState();
    streamSubscription = getLocationWIS().listen((event) {
        print(event[0]);
    });

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
        title: Text("ISS Tracker"),
      ),
      body: _loading ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage("assets/ISSLoading.gif")),
          Text("Loading ISS Location..", style: TextStyle(fontSize: 20),),
        ],
      )) :
      Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height*0.60,
            child: Stack(
              children: [
                GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 3.0,
                        ),
                        markers: _markers.values.toSet(),
                        polylines: _polyline,
                      ),
                (_mapLoading)
                    ? Container(
                  height: MediaQuery.of(context).size.height*0.60,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : Container(),
              ],
            ),


            ),
          SizedBox(height: 10,),
          Expanded(
            child: Center(
              child: Container(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Current Location: " + addressLine, textAlign: TextAlign.center, style: TextStyle(fontSize: 18), maxLines: 4,),
                          Text("Altitude: " + altitude.toStringAsFixed(2) + " km"),
                          Text("Velocity: " + velocity.toStringAsFixed(2) + " km/h"),
                          Text("Visibility: $visibility"),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Latitude: " + latitude.toStringAsFixed(4)),
                        Text("Longitude: " + longitude.toStringAsFixed(4)),
                        Container(
                          width: MediaQuery.of(context).size.width*0.5,
                          //height: MediaQuery.of(context).size.width*0.075,
                          child: ElevatedButton(onPressed: () async {
                            getHumansInSpace();
                          }, child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.supervisor_account),
                              //SizedBox(width: 10,),
                              Flexible(child: Text("Current ISS Crew", textAlign: TextAlign.center,)),
                            ],
                          )),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.5,
                          //height: MediaQuery.of(context).size.width*0.075,
                          child: ElevatedButton(
                            onPressed: (){
                              getReports();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.library_books),
                                //SizedBox(width: 10,),
                                Flexible(child: Text("ISS Daily Reports", textAlign: TextAlign.center,)),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.5,
                          //height: MediaQuery.of(context).size.width*0.075,
                          child: ElevatedButton(
                            onPressed: () async {
                              await canLaunch("https://ustream.tv/channel/17074538") ? await launch("https://ustream.tv/channel/17074538") : throw 'Could not launch https://ustream.tv/channel/17074538';
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewer(url: "https://ustream.tv/channel/17074538", title: "ISS Live Stream",)));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.open_in_new),
                                //SizedBox(width: 10,),
                                Flexible(child: Text("ISS Live Stream", textAlign: TextAlign.center,)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ISSReports extends StatelessWidget {
  List<Reports> reports;
  ISSReports({Key key, @required this.reports}) : super(key: key);
  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
  final DateFormat timeFormatter = DateFormat('HH:MM:SS');
  @override
  Widget build(BuildContext context) {
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("ISS Reports"),
      ),
      body: Center(
        child: ListView.separated(
            itemCount: reports.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index){
              return Container(
                child: Card(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.5,
                              child: Text(reports[index].title, style: TextStyle(fontSize: 18),)),
                          Column(
                            children: [
                              Text(dateFormatter.format(reports[index].date), textAlign: TextAlign.right, style: TextStyle(fontSize: 18),),
                              Text(timeFormatter.format(reports[index].date), textAlign: TextAlign.right, style: TextStyle(fontSize: 18),)
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                        children: [
                          TextSpan(text: reports[index].summary, style: TextStyle(fontSize: 18, color: isDark? Colors.grey[350] : Colors.black),),
                          TextSpan(text: "Read Full Report",
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()..onTap = () async {
                              await canLaunch(reports[index].url) ? await launch(reports[index].url) : throw 'Could not launch ${reports[index].url}';
                              //Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewer(url: reports[index].url, title: "Report Viewer",)));
                            }
                          ),
                          WidgetSpan(
                            child: Icon(Icons.open_in_new, color: Colors.blue,),
                          ),
                        ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("News Site: " + reports[index].newsSite),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

