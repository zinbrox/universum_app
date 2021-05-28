import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore"),
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
            child: Text("Rover Photos"),
            onPressed: (){
              Navigator.pushNamed(context, '/roverSelect');
            },
          ),
          ElevatedButton(
            child: Text("ISS Location"),
            onPressed: (){
              Navigator.pushNamed(context, '/issLoc');
            },
          ),
          ElevatedButton(
            child: Text("Settings"),
            onPressed: (){
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ElevatedButton(
            child: Text("Upcoming Launches"),
            onPressed: (){
              Navigator.pushNamed(context, '/upcomingLaunches');
            },
          ),
          /*
          ElevatedButton(
              onPressed: (){
                print("Started");
                AndroidAlarmManager.periodic(const Duration(seconds: 10), 0, showPrint);
              },
              child: Text("Alarm Manager")),
          ElevatedButton(onPressed: (){
            print("Cancelled");
            AndroidAlarmManager.cancel(0);
            localNotifyManager.cancelAllNotification();

          }, child: Text("Cancel Notifications"))
           */
        ],
      )),
    );
  }
}
