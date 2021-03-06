import 'dart:async';
import 'dart:convert';
import 'package:app_settings/app_settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universum_app/helpers/ad_helper.dart';
import 'package:universum_app/helpers/notificationsPlugin.dart';
import 'package:universum_app/styles/color_styles.dart';


class LaunchDetails {
  String launchName, date, time, windowStartTime, windowStopTime;
  DateTime dateObject;
  String rocketName, rocketFamily;
  String missionName, missionDescription;
  String padName, padLocation, padURL;
  String type, status, holdReason, failReason;
  String imageURL;
  int probability;
  bool notification;

  LaunchDetails({this.launchName, this.date, this.time, this.windowStartTime, this.windowStopTime, this.dateObject, this.rocketName, this.rocketFamily,
    this.missionName, this.missionDescription, this.padName, this.padLocation, this.padURL, this.type,
    this.status, this.imageURL, this.probability, this.holdReason, this.failReason, this.notification});
}

class upcomingLaunches extends StatefulWidget {
  @override
  _upcomingLaunchesState createState() => _upcomingLaunchesState();
}

class _upcomingLaunchesState extends State<upcomingLaunches> {

  // TODO: Add _bannerAd
  BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  List<LaunchDetails> launches = [];


  bool _loading = true, firstTime;
  int statusCode;

  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: Duration(days: 7),
    ),
  );

  Future<void> getLaunches() async {
    print("In getLaunches");
    LaunchDetails launch;
    DateTime date;
    String url = "https://ll.thespacedevs.com/2.0.0/launch/upcoming/";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

      final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormatter = DateFormat('HH:mm:ss');
    print(DateTime.now());

    statusCode = response.statusCode;
    //print(response.statusCode);
    if(statusCode == 200) {


      String rocketName, rocketFamily, missionName, missionDescription, padName,
          padLocation, padURL, type, status, imageURL;
      int probability;
      var pending = await localNotifyManager.returnPendingNotifications();
      List pendingNotifications = [];
      for(var i in pending)
        pendingNotifications.add(i.body);
      print(pendingNotifications);
      for (var results in jsonData['results']) {
        date = DateTime.parse(results['net']).toLocal();
        rocketName =
        results['rocket'] == null ? "" : results['rocket']['configuration'] !=
            null ? results['rocket']['configuration']['full_name'] : "";
        rocketFamily =
        results['rocket'] == null ? "" : results['rocket']['configuration'] !=
            null ? results['rocket']['configuration']['family'] : "";
        missionName =
        results['mission'] == null ? "" : results['mission']['name'] != null
            ? results['mission']['name']
            : "";
        missionDescription =
        results['mission'] == null ? "" : results['mission']['description'] !=
            null ? results['mission']['description'] : "";
        padName = results['pad'] == null ? "" : results['pad']['name'] != null
            ? results['pad']['name']
            : "";
        padLocation =
        results['pad'] == null ? "" : results['pad']['location'] != null
            ? results['pad']['location']['name']
            : "";
        padURL =
        results['pad'] == null ? "" : results['pad']['wiki_url'] != null
            ? results['pad']['wiki_url']
            : "";
        type = results['launch_service_provider'] == null
            ? ""
            : results['launch_service_provider']['type'] != null
            ? results['launch_service_provider']['type']
            : "";
        status =
        results['status'] == null ? "" : results['status']['name'] != null
            ? results['status']['name']
            : "";
        imageURL = results['image'] == null ? null : results['image'];
        probability = results['probability'];

        bool notification = false;
        for(var i in pendingNotifications)
          if(i.contains(results['name']) || i.contains(missionName))
            notification=true;


        launch = LaunchDetails(
          launchName: results['name'],
          date: dateFormatter.format(date),
          time: timeFormatter.format(date),
          windowStartTime: timeFormatter.format(DateTime.parse(results['window_start']).toLocal()),
          windowStopTime: timeFormatter.format(DateTime.parse(results['window_end']).toLocal()),
          dateObject: date,
          rocketName: rocketName,
          rocketFamily: rocketFamily,
          missionName: missionName,
          missionDescription: missionDescription,
          padName: padName,
          padLocation: padLocation,
          padURL: padURL,
          type: type,
          status: status,
          imageURL: imageURL,
          probability: probability,
          holdReason: results['holdreason'],
          failReason: results['failreason'],
          notification: notification,
        );

        launches.add(launch);
      }

    }
    final prefs = await SharedPreferences.getInstance();
    firstTime = prefs.getBool('firstTime')?? true;

    await Future.wait(
      launches.map((launch) {
        cacheImage(context, launch.imageURL);
      }).toList(),
    ).catchError((error){
      print(error);
    });


    
    setState(() {
      _loading=false;
    });


  }

  Future doNothing(){
    return null;
  }
  Future cacheImage(BuildContext context, String imageURL) =>
    precacheImage(
        CachedNetworkImageProvider(imageURL), context);


  void initialiseBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    );

    _bannerAd.load();
  }


  @override
  void initState() {
    super.initState();
    initialiseBanner();
    getLaunches();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Upcoming Launches"),
      ),
      body: _loading? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage("assets/RocketLoading.gif")),
          Text("Loading Upcoming Launches..", style: TextStyle(fontSize: 20),),
        ],
      )) : statusCode==429? Center(child: Text("Too Many Requests! Try again in some time")) :
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: launches.length,
                    itemBuilder: (context, index) {
                    return Container(
                      child: Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                launches[index].imageURL!=null? Image(image: CachedNetworkImageProvider(launches[index].imageURL),) : Center(child: Icon(Icons.error, color: Colors.red,)),
                                //Image(image: NetworkImage(launches[index].imageURL)),
                                /*
                                launches[index].imageURL!=null?
                                CachedNetworkImage(
                                  //filterQuality: FilterQuality.low,
                                  cacheManager: customCacheManager,
                                  key: UniqueKey(),
                                  imageUrl: launches[index].imageURL,
                                  errorWidget: (context, url, error) => Container(
                                    child: Icon(Icons.error, color: Colors.red,),
                                  ),
                                  progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))),
                                ) : Center(child: Icon(Icons.error, color: Colors.red,)),

                                 */
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                      color: Colors.black12,
                                      child: IconButton(icon: launches[index].notification? Icon(Icons.notifications_on, color: Colors.white) : Icon(Icons.notifications_off, color: Colors.white,),
                                        onPressed: () async {
                                          if(firstTime) {
                                            try {
                                              await AppSettings.openNotificationSettings();
                                            }catch(e) {
                                              openAppSettings();
                                            }
                                            Fluttertoast.showToast(
                                                msg: "Please allow all notification permissions to get effective Launch Reminders",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: isDark? Colors.white : Colors.black,
                                                textColor: isDark? Colors.black : Colors.white,
                                                fontSize: 16.0
                                            );
                                            firstTime=false;
                                            final prefs = await SharedPreferences.getInstance();
                                            await prefs.setBool('firstTime', firstTime);
                                          }


                                          else {
                                        if(launches[index].dateObject.isAfter(DateTime.now())) {
                                          print("Started Notification Wait");

                                          var pending = await localNotifyManager.returnPendingNotifications();
                                          List pendingNotifications = [];
                                          for(var i in pending)
                                            pendingNotifications.add(i);

                                          int check=0;
                                          for(var i in pendingNotifications) {
                                            if(i.body.contains(launches[index].launchName)) {
                                              print("Already there. Cancelling Notification");
                                              Fluttertoast.showToast(
                                                  msg: "Reminder Notification turned off for ${launches[index].rocketName}",
                                                  toastLength: Toast.LENGTH_LONG,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: isDark? Colors.white : Colors.black,
                                                  textColor: isDark? Colors.black : Colors.white,
                                                  fontSize: 16.0
                                              );
                                              await localNotifyManager.cancelNotificationID(i.id);
                                              HapticFeedback.vibrate();
                                              check=1;
                                              setState(() {
                                                launches[index].notification=false;
                                              });
                                              break;
                                            }
                                          }
                                          if(check!=1) {
                                            List<int> notificationIDs = [];
                                            List<bool> notificationIDTemp = [];
                                            int newID;
                                            for (var i in pendingNotifications)
                                              notificationIDs.add(i.id);
                                            for(int i=1;i<30;++i) {
                                              if (notificationIDs.contains(i))
                                                notificationIDTemp.add(false);
                                              else
                                                notificationIDTemp.add(true);
                                            }
                                            //print(notificationIDTemp);
                                            for(int i=1;i<30;++i)
                                              if(notificationIDTemp[i-1]) {
                                                newID = i;
                                                break;
                                              }
                                            print("NewID = $newID");
                                            HapticFeedback.vibrate();
                                            Fluttertoast.showToast(
                                                msg: "You'll be reminded 15min before the launch of ${launches[index].rocketName}",
                                                toastLength: Toast.LENGTH_LONG,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: isDark? Colors.white : Colors.black,
                                                textColor: isDark? Colors.black : Colors.white,
                                                fontSize: 16.0
                                            );
                                            print(launches[index].dateObject);
                                            localNotifyManager.scheduleNotification(launches[index].launchName, launches[index].dateObject, newID);
                                            setState(() {
                                              launches[index].notification=true;
                                            });

                                          }

                                        }
                                        else {
                                          print("Launch Over");
                                        }
                                        }
                                      },
                                      )),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.5,
                                    child: launches[index].missionName.isEmpty ? Text(launches[index].launchName, style: TextStyle(fontSize: 25), maxLines: 3,)
                                        : Text(launches[index].missionName, style: TextStyle(fontSize: 25), maxLines: 3,)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text("Date: " + launches[index].date, style: TextStyle(fontSize: 20), textAlign: TextAlign.right,),
                                      Text("Time: " + launches[index].time, style: TextStyle(fontSize: 20), textAlign: TextAlign.right,),
                                      launches[index].windowStartTime!=launches[index].windowStopTime?Text("Window: " + launches[index].windowStartTime + "-" + launches[index].windowStopTime, style: TextStyle(fontSize: 10), textAlign: TextAlign.right,) : Container(),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 5,),
                            Text(launches[index].missionDescription, style: TextStyle(color: isDark? Colors.white70 : Colors.black), textAlign: TextAlign.center,),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Rocket: " + launches[index].rocketName),
                                    Text("Family: " + launches[index].rocketFamily),
                                    Text("Type: " + launches[index].type),
                                  ],
                                ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Pad: " + launches[index].padName, textAlign: TextAlign.right,),
                                      Text("Location: " + launches[index].padLocation, textAlign: TextAlign.right,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              Text("Status: "),
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Text(launches[index].status),
                                decoration: BoxDecoration(
                                  color: launches[index].status=="Success" || launches[index].status=="In Flight" || launches[index].status=="Go"? Colors.green : launches[index].status=="TBD"? Colors.grey : launches[index].status=="Delayed"? Colors.orange : Colors.red,
                                ),
                              ),
                            ],),

                            launches[index].probability!=null && launches[index].probability!=-1? Text("Probability: ${launches[index].probability}%") : Container(),
                            launches[index].holdReason!=null && launches[index].holdReason.length!=0? Text("Hold Reason: ${launches[index].holdReason}", textAlign: TextAlign.center,) : Container(),
                            launches[index].failReason!=null && launches[index].failReason.length!=0? Text("Hold Reason: ${launches[index].failReason}", textAlign: TextAlign.center,) : Container(),

                            StreamBuilder(
                              stream: Stream.periodic(Duration(seconds: 1), (i) => 1),
                                builder: (context, snapshot){
                                if(DateTime.now().isBefore(launches[index].dateObject)) {
                                  DateFormat format = DateFormat("mm:ss");
                                  int now = DateTime.now().millisecondsSinceEpoch;
                                  int estimateTs = launches[index].dateObject.millisecondsSinceEpoch;
                                  Duration remaining = Duration(milliseconds: estimateTs - now);
                                  Format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
                                  return Text("Countdown: " +
                                      Format(remaining).toString(), style: TextStyle(fontSize: 20),);
                                }
                                else
                                  return Container();

                                }),
                            SizedBox(height: 15,),
                          ],
                        ),
                      ),
                    );
                    }),
              ),
              _isBannerAdReady ?
              Container(
                alignment: Alignment.bottomCenter,
                //height: 100,
                //width: MediaQuery.of(context).size.width*0.4,
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ) : Container(),

            ],
          ),

    );
  }
}


