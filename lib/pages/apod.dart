import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'dart:async';

import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class APOD extends StatefulWidget {
  @override
  _APODState createState() => _APODState();
}

class _APODState extends State<APOD> {
  bool _loading=true;
  String mediaType;
  String imageURL, imageTitle, imageDescription, imageCopyRight, imageDate;
  String videoURL;




  Future<void> getAPOD() async {
    print("in getAPOD");
    String url;
    url = "https://api.nasa.gov/planetary/apod?api_key=4bzcuj3O9pBfQzaCONWqeIlD3RbbyaXgjnp9yvxa";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    mediaType = jsonData['media_type'];
    if(mediaType=="image")
      print("Image");
    else
      videoURL = jsonData['url'];
    /*
    imageURL = jsonData['hdurl'];
    //precacheImage(NetworkImage(imageURL), context);
    print(imageURL);
    imageTitle = jsonData['title'];
    imageDescription = jsonData['explanation'];
    imageCopyRight = jsonData['copyright'];
    imageDate = jsonData['date'];

     */
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
      body: _loading ?
      // Shimmer Loading Effect
      Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        enabled: _loading,
        child: ListView.builder(
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 300.0,
                    color: Colors.white,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 8.0,
                    color: Colors.white,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                  ),
                  Container(
                    width: double.infinity,
                    height: 8.0,
                    color: Colors.white,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.0),
                  ),
                  Container(
                    width: 40.0,
                    height: 8.0,
                    color: Colors.white,
                  ),
                ],
              ),
            )
          ),
          itemCount: 5,
        ),
      )
          :
          mediaType=="image" ? Center(child: Text("Image"),)
              :
          YoutubePlayer(
            controller: YoutubePlayerController(
              initialVideoId: YoutubePlayer.convertUrlToId(videoURL), //Add videoID.
              flags: YoutubePlayerFlags(
                hideControls: false,
                controlsVisibleAtStart: true,
                autoPlay: false,
                mute: false,
              ),
            ),
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.pinkAccent,
          ),
          /*
      Center(child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListView(
          children: [
            InkWell(
              onTap: (){
                /*
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: true, // set to false
                    pageBuilder: (_, __, ___) => PictureView(imageURL: imageURL, title: imageTitle,)),
                  );

                 */
                Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: imageURL, title: imageTitle,)));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Hero(
                  tag: "APODPhoto",
                  child: Text(imageURL),
                  /*
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
                  */
                ),
              ),
            ),
            
            SingleChildScrollView(
              child: Column(
                children: [
                  Text(imageTitle),
                  Text(imageDescription),
                  Text(imageDate),
                  imageCopyRight==null ? Container() : Text(imageCopyRight),
                ],
              ),
            ),
          ],
        ),
      ),),
      */
    );
  }
}

class PictureView extends StatelessWidget {
  String imageURL, title;
  PictureView({Key key, @required this.imageURL, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Container(
            child: Hero(
              tag: "APODPhoto",
              child: PhotoView(
                imageProvider: NetworkImage(imageURL),
              ),
            )
        ),
      ),
    );
  }
}

