import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ISSPage extends StatefulWidget {
  @override
  _ISSPageState createState() => _ISSPageState();
}

class _ISSPageState extends State<ISSPage> {

  String message;
  int timestamp;
  String ISSLocLat, ISSLocLong;

  getLocation() async {
    print("In getLocation()");
    String url = "http://api.open-notify.org/iss-now.json?";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    print(jsonData);
    message = jsonData['message'];
    timestamp = jsonData['timestamp'];
    ISSLocLat = jsonData['iss_position']['latitude'];
    ISSLocLong = jsonData['iss_position']['longitude'];
    print(ISSLocLong); print(ISSLocLat);


  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ISS"),
      ),
      body: Center(child: Text("ISS Page")),
    );
  }
}
