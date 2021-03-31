import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
      ),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello"),
          ElevatedButton(
            child: Text("APOD"),
            onPressed: (){
              Navigator.pushNamed(context, '/apod');
            },
          ),
          ElevatedButton(
            child: Text("Weather"),
            onPressed: (){
              Navigator.pushNamed(context, '/marsWeather');
            },
          ),
          ElevatedButton(
            child: Text("Search"),
            onPressed: (){
              Navigator.pushNamed(context, '/search');
            },
          ),
          ElevatedButton(
            child: Text("Settings"),
            onPressed: (){
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      )),
    );
  }
}
