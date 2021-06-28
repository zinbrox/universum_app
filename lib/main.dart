import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universum_app/helpers/sharedPreferencesClass.dart';
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
  MobileAds.instance.initialize();

  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DarkThemeProvider themeChangeProvider =  new DarkThemeProvider();
  FontProvider fontProvider = new FontProvider();
  LaunchNamesProvider launchName = new LaunchNamesProvider();

  List<String> mainImages = ["assets/LoginScreenBackground.jpg", "assets/OrbitFeedLogo.png"];

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
    fontProvider.fontName = await fontProvider.fontPreference.getTheme();
    launchName.launchName = await launchName.launchNamePreference.getNames();
    await Future.wait(
      mainImages.map((item) => cacheImage(context, item)).toList());
      await Future.wait(
        images.map((item) => cacheImage(context, item)).toList());
  }

  Future cacheImage(BuildContext context, String image) => precacheImage(
      AssetImage(image), context);


  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<DarkThemeProvider>(create: (_) => themeChangeProvider),
        ChangeNotifierProvider<FontProvider>(create: (_) => fontProvider),
        ChangeNotifierProvider<LaunchNamesProvider>(create: (_) => launchName)
      ],
      child: Consumer3<FontProvider, DarkThemeProvider, LaunchNamesProvider>(
        builder: (BuildContext, darkTheme, fontName, launchName, child){
          return MaterialApp(
            title: "OrbitFeed",
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, fontProvider.fontName, context),
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
      /*
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            title: "OrbitFeed",
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, fontProvider.fontName, context),
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
      */
    );
  }
}
