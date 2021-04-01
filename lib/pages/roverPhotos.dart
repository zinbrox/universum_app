import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class photoDetails{
  int sol, photoID, cameraID, roverID;
  String cameraName, cameraFullName, imgURL;
  String roverName, roverStatus, earthDate;

  photoDetails({this.sol, this.photoID, this.cameraID, this.cameraName, this.cameraFullName, this.imgURL, this.roverID, this.roverName,
    this.roverStatus, this.earthDate});
}

class roverPhotos extends StatefulWidget {
  @override
  _roverPhotosState createState() => _roverPhotosState();
}

class _roverPhotosState extends State<roverPhotos> {

  List<photoDetails> photosList = [];

  bool _loading=true;

  Future<void> getPhotos() async {
    print("In getPhotos");
    photoDetails item;
    String url = "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?earth_date=2021-03-21&api_key=DEMO_KEY";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    for(var elements in jsonData['photos']){
      print(elements['id'].runtimeType);
      print(elements['sol'].runtimeType);
      print(elements['earth_date'].runtimeType);
      print(elements['id'].runtimeType);
      print(elements['id'].runtimeType);
      item = new photoDetails(
        photoID: elements['id'],
        sol: elements['sol'],
        cameraID: elements['camera']['id'],
        cameraName: elements['camera']['name'],
        cameraFullName: elements['camera']['full_name'],
        imgURL: elements['img_src'],
        earthDate: elements['earth_date'],
        roverID: elements['rover']['id'],
        roverName: elements['rover']['name'],
        roverStatus: elements['rover']['status'],
      );
      photosList.add(item);
    }

    setState(() {
      _loading=false;
    });
  }

  @override
  void initState() {
    super.initState();
    getPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mars Rovers"),
      ),
      body: _loading ? Center(
        child: CircularProgressIndicator(),) :
          ListView.builder(
              itemCount: photosList.length,
              itemBuilder: (context, index){
            return Card(
            elevation: 10,
            child: Column(
            children: <Widget>[
              Image.network(photosList[index].imgURL),
              Text(photosList[index].roverName),
              Text(photosList[index].cameraFullName),
              Text(photosList[index].sol.toString()),
              Text(photosList[index].earthDate),
          ],
            ),
            );
          })
    );
  }
}
