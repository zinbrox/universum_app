import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universum_app/helpers/notificationsPlugin.dart';
import 'package:universum_app/styles/color_styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with AutomaticKeepAliveClientMixin<SettingsPage>{
  @override
  bool get wantKeepAlive => true;

  List<String> fonts = ["Default", 'Retro NASA', 'Star Wars', 'Star Trek', 'Alien', 'Back to the Future'];
  bool notificationSwitch=false;

  showNotification() async {
    var pending = await localNotifyManager.returnPendingNotifications();
    List<String> pendingNotificationsBody = [];
    List<String> pendingNotificationsDate = [];
    DateTime date, now = DateTime.now();
    for(var i in pending) {
      date = DateTime.parse(i.payload.replaceAll("Launch-", ""));
      if(date.isAfter(now)) {
        pendingNotificationsBody.add(i.body.replaceAll(" is launching soon", ""));
        pendingNotificationsDate.add(date.toString());
      }
    }

    await showModalBottomSheet(
        context: context,
        builder: (context) {
      return Container(
        height: 300,
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView.builder(
              itemCount: pendingNotificationsBody == null ? 1 : pendingNotificationsBody.length + 1,
              itemBuilder: (BuildContext context, index){
                if(index==0)
                  return Column(
                    children: [
                      ListTile(
                        title: Text("Notification", style: TextStyle(fontSize: 20),),
                        trailing: Text("Time", style: TextStyle(fontSize: 20),),
                      ),
                      //Divider(color: isSwitched? Colors.white : Colors.black,),
                    ],
                  );
                index-=1;
                if(pendingNotificationsBody.length==0)
                  return Center(child: Text("No pending Notifications"),);
                return ListTile(
                  title: Text(pendingNotificationsBody[index]),
                  trailing: Text(pendingNotificationsDate[index]),
                );
              }),
        ),
      );
    });
  }

  getNotificationSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    notificationSwitch=prefs.getBool('APODNotification')?? false;
    setState(() {
    });
  }



  @override
  void initState() {
    super.initState();
    getNotificationSwitch();
  }

  @override
  Widget build(BuildContext context) {
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isSwitched = _themeChanger.darkTheme;
    final _fontChanger = Provider.of<FontProvider>(context);
    String fontName = _fontChanger.fontName;
    String dropdownValue = fontName;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text("Daily Notification"),
                  subtitle: Text("We'll send you the Picture of the Day"),
                  trailing: IconButton(
                    icon: notificationSwitch? Icon(Icons.notifications_active) : Icon(Icons.notifications_off),
                    onPressed: () async {
                      setState(() {
                        notificationSwitch = !notificationSwitch;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('APODNotification', notificationSwitch);

                      if(notificationSwitch) {
                        await FirebaseMessaging.instance.subscribeToTopic('apod');
                        print("Daily Notifications turned on");
                        HapticFeedback.vibrate();
                        Fluttertoast.showToast(
                            msg: "Daily Notifications turned on",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: isSwitched? Colors.white : Colors.black,
                            textColor: isSwitched? Colors.black : Colors.white,
                            fontSize: 16.0
                        );


                      }
                      else {
                        print("Cancelled Notifications");
                        await FirebaseMessaging.instance.unsubscribeFromTopic('apod');
                        Fluttertoast.showToast(
                            msg: "Daily Notifications turned off",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: isSwitched? Colors.white : Colors.black,
                            textColor: isSwitched? Colors.black : Colors.white,
                            fontSize: 16.0
                        );
                      }
                    },
                  ),
                ),

                ListTile(
                  title: Text("Theme"),
                  subtitle: isSwitched? Text("Dark Mode") : Text("Light Mode"),
                  trailing: Switch(
                    activeColor: Colors.orange,
                    value: isSwitched,
                    onChanged: (value){
                      setState(() {
                        isSwitched=value;
                        isSwitched? _themeChanger.darkTheme=true : _themeChanger.darkTheme=false;
                      });
                    },
                  ),
                ),

                ListTile(
                  title: Text("Font"),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      onChanged: (String newValue){
                        setState(() {
                          dropdownValue = newValue;
                          _fontChanger.fontName=newValue;
                        });
                      },
                      items: <String>['Default', 'Retro NASA', 'Alien', 'Comfortaa'].map<DropdownMenuItem<String>>((String value){
                        return DropdownMenuItem<String>(value: value, child: Text(value),);
                      }).toList(),
                      ),
                  ),
                  ),
                ListTile(
                  title: Text("Clear Cache"),
                  subtitle: Text("This can affect loading of images"),
                  //trailing: Icon(Icons.navigate_next),
                  onTap: () async {
                    var appDir = (await getTemporaryDirectory()).path;
                    print(appDir);
                    new Directory(appDir).delete(recursive: true);
                    Fluttertoast.showToast(
                        msg: "Cache Cleared",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: isSwitched? Colors.white : Colors.black,
                        textColor: isSwitched? Colors.black : Colors.white,
                        fontSize: 16.0
                    );
                  },
                ),
                ListTile(
                  title: Text("Pending Notifications"),
                  subtitle: Text("View scheduled Launch Reminders"),
                  onTap: () {
                    showNotification();
                  },
                ),
                ListTile(
                  title: Text("Credits"),
                  onTap: () async {
                    await showModalBottomSheet(
                        context: context,
                        builder: (context) {
                      return Container(
                        height: MediaQuery.of(context).size.height*0.6,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text("Content", style: TextStyle(fontSize: 20),),
                              trailing: Text("Source", style: TextStyle(fontSize: 20),),
                            ),
                            Divider(color: isSwitched? Colors.white : Colors.black,),
                            ListTile(
                              title: Text("Rover Images"),
                              trailing: Text("NASA"),
                            ),
                            ListTile(
                              title: Text("Picture of the Day"),
                              trailing: Text("NASA"),
                            ),
                            ListTile(
                              title: Text("ISS Tracker"),
                              trailing: Text("wheretheiss.at"),
                            ),
                            ListTile(
                              title: Text("Upcoming Launches & Articles"),
                              trailing: Text("thespacedevs"),
                            ),
                          ],
                        ),
                      );
                    });
                    Fluttertoast.showToast(
                        msg: "If you like the app, please do rate it!",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: isSwitched? Colors.white : Colors.black,
                        textColor: isSwitched? Colors.black : Colors.white,
                        fontSize: 16.0
                    );
                  },
                ),
              ],
            ),
          ),
          Text("zinbrox", style: TextStyle(decoration: TextDecoration.overline, fontSize: 15),),
          SizedBox(height: 10,)
        ],
      ),
    );
  }
}


Future<void> callAPODNotification() async {
  await localNotifyManager.repeatNotification();
}

