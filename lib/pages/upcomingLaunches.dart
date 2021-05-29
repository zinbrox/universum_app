import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:universum_app/helpers/ad_helper.dart';

class LaunchDetails {
  String launchName, date, time;
  DateTime dateObject;
  String rocketName, rocketFamily;
  String missionName, missionDescription;
  String padName, padLocation, padURL;
  String type, status;
  String imageURL;

  LaunchDetails({this.launchName, this.date, this.time, this.dateObject, this.rocketName, this.rocketFamily, this.missionName, this.missionDescription, this.padName, this.padLocation, this.padURL, this.type, this.status, this.imageURL});
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

  bool _loading = true;
  int statusCode;

  Future<void> getLaunches() async {
    print("In getLaunches");
    LaunchDetails launch;
    DateTime date;
    String url = "https://ll.thespacedevs.com/2.0.0/launch/upcoming/";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

      final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');
    final DateFormat timeFormatter = DateFormat('HH:MM:SS');
    print(DateTime.now());

    statusCode = response.statusCode;
    //print(response.statusCode);
    if(statusCode == 200) {
      String rocketName, rocketFamily, missionName, missionDescription, padName,
          padLocation, padURL, type, status, imageURL;
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
        launch = LaunchDetails(
          launchName: results['name'],
          date: dateFormatter.format(date),
          time: timeFormatter.format(date),
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
        );

        launches.add(launch);
      }
    }

    await Future.wait(
      launches.map((launch) => cacheImage(context, launch.imageURL)).toList(),
    );
    
    setState(() {
      _loading=false;
    });


  }

  Future cacheImage(BuildContext context, String imageURL) => precacheImage(
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Upcoming Launches"),
      ),
      body: _loading? Center(child: CircularProgressIndicator(),) : statusCode==429? Center(child: Text("Too Many Requests! Try again in some time")) :
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
                                Image(image: CachedNetworkImageProvider(launches[index].imageURL),),
                                //Image(image: NetworkImage(launches[index].imageURL)),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                      color: Colors.black12,
                                      child: IconButton(icon: Icon(Icons.notifications, color: Colors.white,), onPressed: (){},)),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width*0.5,
                                    child: Text(launches[index].missionName, style: TextStyle(fontSize: 25), maxLines: 2,)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text("Date: " + launches[index].date, style: TextStyle(fontSize: 20,)),
                                      Text("Time: " + launches[index].time, style: TextStyle(fontSize: 20),),
                                    ],
                                  ),
                                ),

                              ],
                            ),

                            Text(launches[index].missionDescription),
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
                                      Text("Pad: " + launches[index].padName),
                                      Text("Location: " + launches[index].padLocation, textAlign: TextAlign.center,),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

                            StreamBuilder(
                              stream: Stream.periodic(Duration(seconds: 1), (i) => 1),
                                builder: (context, snapshot){
                                if(DateTime.now().isBefore(launches[index].dateObject)) {
                                  DateFormat format = DateFormat("mm:ss");
                                  int now = DateTime.now().millisecondsSinceEpoch;
                                  int estimateTs = launches[index].dateObject.millisecondsSinceEpoch;
                                  Duration remaining = Duration(milliseconds: estimateTs - now);
                                  Format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
                                  /*
                                  var dateString = '${remaining.inDays}:${remaining.inHours}:${format.format(
                                      DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';

                                   */
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
  _returnCountdown(int index){
    /*
    if(DateTime.now().isBefore(launches[index].dateObject)) {
      Duration difference = launches[index].dateObject.difference(
          DateTime.now());
      //return Text("CountDown: " + difference.toString());
      return difference;
    }

     */
    return launches[index].dateObject.difference(DateTime.now());
  }
}
