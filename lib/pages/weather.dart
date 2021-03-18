import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MarsWeather extends StatefulWidget {
  @override
  _MarsWeatherState createState() => _MarsWeatherState();
}

class _MarsWeatherState extends State<MarsWeather> {

  Future<void> getWeather() async {
    print("In getWeather()");
    String url;
    var details = new Map();
    List<Map> Details = new List<Map>();
    url = "https://api.nasa.gov/insight_weather/?api_key=DEMO_KEY&feedtype=json&ver=1.0";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    var solKeys = jsonData['sol_keys'];
    for(var i in solKeys) {
      details = new Map();
      details['First_UTC'] = jsonData[i]['First_UTC'];
      details['Last_UTC'] = jsonData[i]['Last_UTC'];
      details['PRE'] = jsonData[i]['PRE'];
      details['AT'] = jsonData[i]['AT'];
      details['HWS'] = jsonData[i]['HWS'];
      details['WD'] = jsonData[i]['WD'];
      Details.add(details);
    }
    print(Details);


  }

  @override
  void initState() {
    super.initState();
    getWeather();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather"),
        centerTitle: true,
      ),
      body: Center(child: Text("Weather"),),
    );
  }
}
