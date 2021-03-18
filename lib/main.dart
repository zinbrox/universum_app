import 'package:flutter/material.dart';
import 'package:universum_app/pages/home.dart';
import 'package:universum_app/pages/apod.dart';
import 'package:universum_app/pages/weather.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home':(context) => Home(),
        '/apod':(context) => APOD(),
        '/marsWeather':(context) => MarsWeather(),
      },
    );
  }
}
