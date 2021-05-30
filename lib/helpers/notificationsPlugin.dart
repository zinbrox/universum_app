import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universum_app/helpers/sharedPreferencesClass.dart';
import 'package:universum_app/pages/upcomingLaunches.dart';

class LocalNotifyManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initializationSettings;

  BehaviorSubject<
      ReceivedNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceivedNotification>();

  LocalNotifyManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  requestIOSPermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>().requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  initializePlatformSpecifics() {
    var initSettingAndroid = new AndroidInitializationSettings(
        'notification_icon_logo');
    var initSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id, title: title, body: body, payload: payload);
        didReceiveLocalNotificationSubject.add(receivedNotification);
      },
    );
    initializationSettings = InitializationSettings(
        android: initSettingAndroid, iOS: initSettingsIOS);
  }

  setListenerForLowerVersions(Function onNotificationInLowerVersions) {
    didReceiveLocalNotificationSubject.listen((receivedNotification) {
      onNotificationInLowerVersions(receivedNotification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
          onNotificationClick(payload);
        });
  }


  Future<void> showNotification() async {
    print("In showNotification");
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL 1',
      'Launch Notifications',
      "Launch Reminders",
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);

    //_getLaunches();
    List<String> names = await SharedPrefUtils.readPrefStr('launchNames');
    print(names);
    String name;
    if(names.isEmpty)
      name = "Launch happening soon";
    else
      name = "${names[0]} will be launching soon";
      await flutterLocalNotificationsPlugin.show(
        1,
        'LAUNCH REMINDER!',
        '$name', //null
        platformChannelSpecifics,
        payload: 'New Payload',
      );
      names.remove(names[0]);
      SharedPrefUtils.saveStr('launchNames', names);
      print(SharedPrefUtils.readPrefStr('launchNames'));
    }
  List<LaunchDetails> launches = []; int statusCode;

  _getLaunches() async {
    LaunchDetails launch;
    DateTime date;
    String url = "https://ll.thespacedevs.com/2.0.0/launch/upcoming/";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    statusCode = response.statusCode;
    //print(response.statusCode);
    if(statusCode == 200) {
      String rocketName, rocketFamily, missionName, missionDescription, padName,
          padLocation, padURL, type, status, imageURL;
      for (var results in jsonData['results']) {
        date = DateTime.parse(results['net']).toLocal();
        missionName =
        results['mission'] == null ? "" : results['mission']['name'] != null
            ? results['mission']['name']
            : "";
        launch = LaunchDetails(
          launchName: results['name'],
          missionName: missionName,
          dateObject: date,
        );

        launches.add(launch);
      }
      launches.sort((a,b) => a.dateObject.compareTo(b.dateObject));
    }
  }

  _downloadAndSaveFile(String url, String fileName) async {
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$fileName';
    print(filePath);
    var response = await http.get(Uri.parse(url));
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> repeatNotification() async {
    print("In repeatNotification");
    getAPOD();
    if(mediaType=="image") {
      var attachmentPicturePath = await _downloadAndSaveFile(
          imageURL, 'attachment_img.jpg');
      var iOSPlatformSpecifics = IOSNotificationDetails(
        attachments: [IOSNotificationAttachment(attachmentPicturePath)],
      );
      var bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(attachmentPicturePath),
        contentTitle: '$contentTitle',
        htmlFormatContentTitle: true,
        summaryText: contentDescription,
        htmlFormatSummaryText: true,
      );

      var androidChannelSpecifics = AndroidNotificationDetails(
        'Channel 1',
        'Picture of the Day',
        "NASA Astronomical Picture of the Day",
        importance: Importance.max,
        priority: Priority.max,
        onlyAlertOnce: false,
        largeIcon: FilePathAndroidBitmap(picturePath),
        styleInformation: bigPictureStyleInformation,
      );
      var iosChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics =
      NotificationDetails(
          android: androidChannelSpecifics, iOS: iosChannelSpecifics);


      await flutterLocalNotificationsPlugin.show(
        0,
        contentTitle,
        contentDescription,
        platformChannelSpecifics,
        payload: 'Test Payload',

      );
    }
  }

  String mediaType, imageURL, contentTitle, contentDescription, contentCopyRight, contentDate;
  var picturePath;

  Future<void> getAPOD() async {
    print("in getAPOD");
    String url;
    url = "https://api.nasa.gov/planetary/apod?api_key=4bzcuj3O9pBfQzaCONWqeIlD3RbbyaXgjnp9yvxa";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    mediaType = jsonData['media_type'];
    if(mediaType=="image") {
      imageURL = jsonData['hdurl'];
      contentTitle = jsonData['title'];
      contentDescription = jsonData['explanation'];
    }
    print(mediaType);

  }


  Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}


LocalNotifyManager localNotifyManager = LocalNotifyManager.init();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  ReceivedNotification({@required this.id, @required this.title, @required this.body, @required this.payload});
}