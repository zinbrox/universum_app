import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universum_app/helpers/notificationsPlugin.dart';
import 'package:universum_app/styles/color_styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
                            const Duration(days: 1), 0,
                            callAPODNotification,
                          exact: true,
                          startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
                          rescheduleOnReboot: true,
                        );
                      }
                        else {
                          print("Notifications Cancelled");
                          AndroidAlarmManager.cancel(0);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text("Change Font"),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    _changeFont();
                  },
                ),
                ListTile(
                  title: Text("Theme"),
                  subtitle: Text("Light/ Dark mode"),
                  trailing: Switch(
                    value: isSwitched,
                    onChanged: (value){
                      setState(() {
                        isSwitched=value;
                        isSwitched? _themeChanger.darkTheme=true : _themeChanger.darkTheme=false;
                      });
                    },
                  ),
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
