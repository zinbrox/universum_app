import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universum_app/helpers/notificationsPlugin.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  void initState() {
    super.initState();
    localNotifyManager.setListenerForLowerVersions(onNotificationInLowerVersions);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
  Future onNotificationClick(String payload) {
    print("Pressed Notification");
    print("Payload: $payload");
  }

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
        ],
      )),
    );
  }
}

showPrint() {
  localNotifyManager.repeatNotification();
}
