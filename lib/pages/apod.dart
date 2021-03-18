import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class APOD extends StatefulWidget {
  @override
  _APODState createState() => _APODState();
}

class _APODState extends State<APOD> {
  bool _loading=true;
  String imageURL, imageTitle, imageDescription, imageCopyRight, imageDate;

  Future<void> getAPOD() async {
    print("in getAPOD");
    String url;
    url = "https://api.nasa.gov/planetary/apod?api_key=4bzcuj3O9pBfQzaCONWqeIlD3RbbyaXgjnp9yvxa";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    imageURL = jsonData['hdurl'];
    print(imageURL);
    imageTitle = jsonData['title'];
    imageDescription = jsonData['explanation'];
    imageCopyRight = jsonData['copyright'];
    imageDate = jsonData['date'];
    setState(() {
      _loading=false;
    });
  }

  @override
  void initState() {
    print(_loading);
    super.initState();
    getAPOD();
    print(_loading);
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Astronomical Picture of the Day"),
        centerTitle: true,
      ),
      body: _loading ? Center(child: CircularProgressIndicator(),) :
      Center(child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: FadeInImage.assetNetwork(
                  placeholder: 'assets/LoadingGif.gif',
                  imageErrorBuilder: (BuildContext context,
                      Object exception,
                      StackTrace stackTrace) {
                    return Column(
                      children: [
                        Text("Couldn't Load Image"),
                      ],
                    );
                  },
                  image: imageURL),
            ),
            
            SingleChildScrollView(
              child: Column(
                children: [
                  Text(imageTitle),
                  Text(imageDescription),
                  Text(imageDate),
                  Text(imageCopyRight),
                ],
              ),
            ),
          ],
        ),
      ),),
    );
  }
}
