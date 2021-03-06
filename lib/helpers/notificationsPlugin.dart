import 'dart:convert';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show File, Platform;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

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

  returnPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests;
  }

  Future<void> scheduleNotification(String launchName, DateTime date, int newID) async {
    print("In scheduleNotification");

    tz.initializeTimeZones();
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL 1',
      'Launch Notifications',
      "Launch Reminders",
      importance: Importance.max,
      priority: Priority.max,
      enableLights: true,
      enableVibration: true,
      showWhen: true,
      color: Colors.orange,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(''),
    );

    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
    NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);

    /*
    var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 10));
    var timeInUtc = DateTime.now().toUtc();
     */
    //Duration remaining = Duration(minutes: 1);
    Duration remaining = date.difference(DateTime.now().add(const Duration(minutes: 15)));
    print(tz.TZDateTime.now(tz.local).add(remaining));


    await flutterLocalNotificationsPlugin.zonedSchedule(
      newID,
      'LAUNCH REMINDER',
      '$launchName is launching soon',
      tz.TZDateTime.now(tz.local).add(remaining),
      //date.toUtc().subtract(const Duration(minutes: 15)),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      payload: 'Launch-$date',
    );


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
    await getAPOD();
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
        importance: Importance.high,
        priority: Priority.high,
        onlyAlertOnce: false,
        enableLights: true,
        enableVibration: true,
        showWhen: true,
        color: Colors.orange,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
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
        payload: 'APOD',

      );
    }
  }

  String mediaType, imageURL, contentTitle, contentDescription;
  var picturePath;

  Future<void> getAPOD() async {
    print("in getAPOD");
    String url;
    url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    mediaType = jsonData['media_type'];
    print("Hello");
    if(mediaType=="image") {
      imageURL = jsonData['url'];
      contentTitle = jsonData['title'];
      contentDescription = jsonData['explanation'];
    }
    print(mediaType);
    return;

  }

  Future<void> cancelNotificationID(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
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