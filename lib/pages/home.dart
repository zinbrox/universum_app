import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universum_app/helpers/notificationsPlugin.dart';
import 'package:universum_app/pages/explorePage.dart';
import 'package:universum_app/pages/homePage.dart';
import 'package:universum_app/pages/settingsPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentIndex=0;
  final tabs=[
    HomePage(),
    ExplorePage(),
    SettingsPage(),
  ];

  final pageController = PageController();
  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }


  void initState() {
    super.initState();
    localNotifyManager.setListenerForLowerVersions(onNotificationInLowerVersions);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {}
  Future onNotificationClick(String payload) {
    print("Pressed Notification");
    print("Payload: $payload");
    if(payload=="APOD")
      Navigator.pushNamed(context, '/apod');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home Page"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Search Page"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings Page"),
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
          pageController.jumpToPage(index);
        },
      ),
      body: PageView(
        children: tabs,
        controller: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}

showPrint() {
  localNotifyManager.repeatNotification();
}
