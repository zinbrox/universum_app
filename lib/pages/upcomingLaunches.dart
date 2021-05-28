import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  List<LaunchDetails> launches = [];

  bool _loading = true;

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
    //print(jsonData['results']);
    /*
    if(DateTime.now().isUtc)
      print("Yes");
    else
      print("No");

     */

    for(var results in jsonData['results']) {
      date = DateTime.parse(results['net']).toLocal();
      //print(results['rocket']['configuration']['full_name']);
      

      launch = LaunchDetails(
        launchName: results['name']?? "",
        date: dateFormatter.format(date)?? "",
        time: timeFormatter.format(date)?? "",
        dateObject: date ?? DateTime.now(),
        rocketName: results['rocket']['configuration']['full_name']?? "",
        rocketFamily: results['rocket']['configuration']['family']?? "",
        missionName: results['mission']['name']?? "",
        missionDescription: results['mission']['description']?? "",
        padName: results['pad']['name']?? "",
        padLocation: results['pad']['location']['name']?? "",
        padURL: results['pad']['wiki_url']?? "",
        type: results['launch_service_provider']['type']?? "",
        status: results['status']['name']?? "",
        imageURL: results['image']?? "",
      );
      print(launch.rocketName);
      print(launch.missionName);
      print(launch.padName);
      print(launch.type);
      print(launch.status);
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
              return Text("Hello");
              /*
                Container(
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image(image: NetworkImage(launches[index].imageURL)),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                                color: Colors.black12,
                                child: IconButton(icon: Icon(Icons.notifications, color: Colors.white,), onPressed: (){},)),
                          ),
                        ],
                      ),
                      //Text("Name: " + launches[index].launchName),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Text(launches[index].missionName, style: TextStyle(fontSize: 25),),
                          Column(
                            children: [
                              Text("Date: " + launches[index].date, style: TextStyle(fontSize: 20),),
                              Text("Time: " + launches[index].time, style: TextStyle(fontSize: 20),),
                            ],
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
                                Text("Location: " + launches[index].padLocation),
                              ],
                            ),
                          ),
                        ],
                      ),
                      //Text("Status: " + launches[index].status),

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
              */
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
