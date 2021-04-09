import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universum_app/pages/home.dart';
import 'package:universum_app/pages/apod.dart';
import 'package:universum_app/pages/iss.dart';
import 'package:universum_app/pages/loginPage.dart';
import 'package:universum_app/pages/roverPhotos.dart';
import 'package:universum_app/pages/settingsPage.dart';
import 'package:universum_app/pages/weather.dart';
import 'package:universum_app/pages/search.dart';
import 'package:universum_app/styles/color_styles.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DarkThemeProvider themeChangeProvider =  new DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            initialRoute: '/loginPage',
            routes: {
              '/loginPage':(context) => LoginPage(),
              '/home':(context) => Home(),
              '/apod':(context) => APOD(),
              '/marsWeather':(context) => MarsWeather(),
              '/search':(context) => NASASearch(),
              '/settings':(context) => SettingsPage(),
              '/roverPhotos':(context) => roverPhotos(),
              '/issLoc':(context) => ISSPage(),

            },
          );
        },
      ),
    );
  }
}
