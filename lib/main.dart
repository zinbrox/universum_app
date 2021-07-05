import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:universum_app/pages/home.dart';
import 'package:universum_app/pages/apod.dart';
import 'package:universum_app/pages/iss.dart';
import 'package:universum_app/pages/loginPage.dart';
import 'package:universum_app/pages/roverPhotos.dart';
import 'package:universum_app/pages/settingsPage.dart';
import 'package:universum_app/pages/upcomingLaunches.dart';
import 'package:universum_app/pages/search.dart';
import 'package:universum_app/styles/color_styles.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AndroidAlarmManager.oneShot(Duration(seconds: 1), 0, callAPODNotification, wakeup: true, exact: true, rescheduleOnReboot: true, allowWhileIdle: true, alarmClock: true);
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DarkThemeProvider themeChangeProvider =  new DarkThemeProvider();
  FontProvider fontProvider = new FontProvider();

  List<String> mainImages = ["assets/LoginScreenBackground.jpg", "assets/OrbitFeedLogo.png"];

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
    fontProvider.fontName = await fontProvider.fontPreference.getTheme();
    await Future.wait(
      mainImages.map((item) => cacheImage(context, item)).toList());
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
      ],
      child: Consumer2<FontProvider, DarkThemeProvider>(
        builder: (BuildContext, darkTheme, fontName, child){
          return MaterialApp(
            title: "OrbitFeed",
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, fontProvider.fontName, context),
            initialRoute: '/loginPage',
            routes: {
              '/loginPage':(context) => LoginPage(),
              '/home':(context) => Home(),
              '/apod':(context) => APOD(),
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



