import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LaunchDetails {
  String launchName, date, time;
  DateTime dateObject;
  String rocketName, rocketFamily;
  String missionName, missionDescription;
  String padName, padLocation, padURL;
  String type;
  String imageURL;

  LaunchDetails({this.launchName, this.date, this.time, this.dateObject, this.rocketName, this.rocketFamily, this.missionName, this.missionDescription, this.padName, this.padLocation, this.padURL, this.type, this.imageURL});
}

class upcomingLaunches extends StatefulWidget {
  @override
  _upcomingLaunchesState createState() => _upcomingLaunchesState();
}

class _upcomingLaunchesState extends State<upcomingLaunches> {

  List<LaunchDetails> launches = [];

  bool _loading = true;

  Future<void> getLaunches() async {
    print("In getLaunches");
    LaunchDetails launch;
    DateTime date;
    String url = "https://ll.thespacedevs.com/2.0.0/launch/upcoming/";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormatter = DateFormat('HH:MM:SS');
    print(DateTime.now());
    /*
    if(DateTime.now().isUtc)
      print("Yes");
    else
      print("No");

     */

    for(var results in jsonData['results']) {
      date = DateTime.parse(results['net']).toLocal();
      //print(date);
      

      launch = LaunchDetails(
        launchName: results['name'],
        date: dateFormatter.format(date),
        time: timeFormatter.format(date),
        dateObject: date,
        rocketName: results['rocket']['full_name'],
        rocketFamily: results['rocket']['family'],
        missionName: results['mission']['name'],
        missionDescription: results['mission']['description'],
        padName: results['pad']['name'],
        padLocation: results['pad']['location']['name'],
        padURL: results['pad']['wiki_url'],
        type: results['launch_service_provider']['type'],
        imageURL: results['image'],
      );
      launches.add(launch);
    }

    setState(() {
      _loading=false;
    });


  }

  @override
  void initState() {
    super.initState();
    getLaunches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upcoming Launches"),
      ),
      body: _loading? Center(child: CircularProgressIndicator(),) :
          ListView.builder(
            itemCount: launches.length,
              itemBuilder: (context, index) {
              return Container(
                child: Column(
                  children: [
                    Image(image: NetworkImage(launches[index].imageURL)),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                          children: [
                            Text("Name: \n" + launches[index].launchName),
                            Text("Mission Name: " + launches[index].missionName),
                            Text("Mission Description: " + launches[index].missionDescription),
                            Text("Type: " + launches[index].type),
                          ],
                        ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text("Date: " + launches[index].date),
                              Text("Time: " + launches[index].time),
                              Text("Pad: " + launches[index].padName),
                              Text("Pad Location: " + launches[index].padLocation),

                              StreamBuilder(
                                stream: Stream.periodic(Duration(seconds: 1), (i) => 1),
                                  builder: (context, snapshot){
                                  if(DateTime.now().isBefore(launches[index].dateObject)) {
                                    DateFormat format = DateFormat("mm:ss");
                                    int now = DateTime
                                        .now()
                                        .millisecondsSinceEpoch;
                                    int estimateTs = launches[index].dateObject
                                        .millisecondsSinceEpoch;
                                    Duration remaining = Duration(
                                        milliseconds: estimateTs - now);
                                    Format(Duration d) =>
                                        d
                                            .toString()
                                            .split('.')
                                            .first
                                            .padLeft(8, "0");
                                    /*
                                    var dateString = '${remaining.inDays}:${remaining.inHours}:${format.format(
                                        DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds))}';

                                     */
                                    return Text("Countdown: " +
                                        Format(remaining).toString());
                                  }
                                  else
                                    return Container();

                                  }),



                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              })
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
