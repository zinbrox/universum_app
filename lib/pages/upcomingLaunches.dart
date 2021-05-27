import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LaunchDetails {
  String launchName, date;
  String rocketName, rocketFamily;
  String missionName, missionDescription;
  String padName, padLocation, padURL;
  String type;
  String imageURL;

  LaunchDetails({this.launchName, this.date, this.rocketName, this.rocketFamily, this.missionName, this.missionDescription, this.padName, this.padLocation, this.padURL, this.type, this.imageURL});
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
    String url = "https://ll.thespacedevs.com/2.0.0/launch/upcoming/";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    for(var results in jsonData['results']) {
      launch = LaunchDetails(
        launchName: results['name'],
        date: results['net'],
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
    // TODO: implement initState
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
                              Text("Pad: " + launches[index].padName),
                              Text("Pad Location: " + launches[index].padLocation),
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
}
