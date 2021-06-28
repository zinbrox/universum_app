import 'dart:io';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universum_app/helpers/notificationsPlugin.dart';
import 'package:universum_app/helpers/sharedPreferencesClass.dart';
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

  _changeFont() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
      return Container(
        height: 300,
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView.builder(
              itemCount: fonts.length,
              itemBuilder: (BuildContext context, index){
                return CheckboxListTile(
                    value: false, onChanged: (bool value){

                },
                  title: Text(fonts[index]),
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
    final _launchNamesChanger = Provider.of<LaunchNamesProvider>(context);
    List<String> launchNames = _launchNamesChanger.launchName;

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
                  trailing: Switch(
                    activeColor: Colors.orange,
                    value: notificationSwitch,
                    onChanged: (value) async {
                      setState((){
                        notificationSwitch=value;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('APODNotification', notificationSwitch);
                      if(notificationSwitch) {
                        print("Notifications Started");
                        AndroidAlarmManager.periodic(
                            const Duration(minutes: 1), 0,
                            callAPODNotification,
                          exact: true,
                          startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
                          rescheduleOnReboot: true,
                        );
                        Fluttertoast.showToast(
                            msg: "Daily Notifications turned on",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            fontSize: 16.0
                        );
                      }
                        else {
                          print("Notifications Cancelled");
                          AndroidAlarmManager.cancel(0);
                          Fluttertoast.showToast(
                              msg: "Daily Notifications turned off",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.white,
                              textColor: Colors.black,
                              fontSize: 16.0
                          );
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text("Font"),
                  /*
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    _changeFont();
                  },
                   */
                  trailing: DropdownButton<String>(
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


                //Text(dropdownValue),
                /*
                ListTile(
                  title: Text(launchNames.toString()),
                  onTap: (){
                    print("Removed");
                    launchNames.clear();
                  },
                ),

                 */
                //Text(launchNames.toString()),
                ListTile(
                  title: Text("Theme"),
                  subtitle: Text("Light/ Dark mode"),
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
                  title: Text("Clear Cache"),
                  subtitle: Text("This can affect loading of images"),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () async {
                    var appDir = (await getTemporaryDirectory()).path;
                    print(appDir);
                    new Directory(appDir).delete(recursive: true);
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
                  },
                ),
              ],
            ),
          ),
          Text("zinbrox", style: TextStyle(decoration: TextDecoration.overline, fontSize: 15),),
          SizedBox(height: 10,)
        ],
      ),
      /*
      Center(
        child: Switch(
          value: isSwitched,
          onChanged: (value){
            setState(() {
              isSwitched=value;
              isSwitched? _themeChanger.darkTheme=true : _themeChanger.darkTheme=false;
            });
          },
        ),
      ),
      */
    );
  }
}

callAPODNotification(){
  localNotifyManager.repeatNotification();
}
