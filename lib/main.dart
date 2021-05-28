import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:universum_app/pages/explorePage.dart';
import 'package:universum_app/pages/home.dart';
import 'package:universum_app/pages/apod.dart';
import 'package:universum_app/pages/iss.dart';
import 'package:universum_app/pages/loginPage.dart';
import 'package:universum_app/pages/roverPhotos.dart';
import 'package:universum_app/pages/settingsPage.dart';
import 'package:universum_app/pages/upcomingLaunches.dart';
import 'package:universum_app/pages/weather.dart';
import 'package:universum_app/pages/search.dart';
import 'package:universum_app/styles/color_styles.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  //MobileAds.instance.initialize();
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
              '/roverSelect':(context) => roverSelect(),
              '/roverPhotos':(context) => roverPhotos(),
              '/issLoc':(context) => ISSPage(),
              '/upcomingLaunches':(context) => upcomingLaunches(),
            },
          );
        },
      ),
    );
  }
}
