import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universum_app/styles/color_styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  List<String> fonts = ["Default", 'Retro NASA', 'Star Wars', 'Star Trek', 'Alien', 'Back to the Future'];

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
          Text("zinbrox", style: TextStyle(decoration: TextDecoration.overline),)
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
