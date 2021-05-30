import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'dart:async';

import 'package:shimmer/shimmer.dart';
import 'package:universum_app/helpers/ad_helper.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class APOD extends StatefulWidget {
  @override
  _APODState createState() => _APODState();
}

class _APODState extends State<APOD> {

  // TODO: Add _bannerAd
  BannerAd _bannerAd;

  // TODO: Add _isBannerAdReady
  bool _isBannerAdReady = false;

  bool _loading=true;
  String mediaType;
  String imageURL, contentTitle, contentDescription, contentCopyRight, contentDate;
  String videoURL;




  Future<void> getAPOD() async {
    print("in getAPOD");
    String url;
    url = "https://api.nasa.gov/planetary/apod?api_key=4bzcuj3O9pBfQzaCONWqeIlD3RbbyaXgjnp9yvxa";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    mediaType = jsonData['media_type'];
    if(mediaType=="image") {
      imageURL = jsonData['hdurl'];
      await precacheImage(CachedNetworkImageProvider(imageURL), context);
    }
    else {
      videoURL = jsonData['url'];
    }

    contentTitle = jsonData['title'];
    contentDescription = jsonData['explanation'];
    contentCopyRight = jsonData['copyright'];
    contentDate = jsonData['date'];


    setState(() {
      _loading=false;
    });
  }

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
    getAPOD();
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
        baseColor: Colors.white,
        highlightColor: Colors.white70,
        enabled: _loading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.4,
              width: MediaQuery.of(context).size.width*0.9,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              height: MediaQuery.of(context).size.height*0.025,
              width: MediaQuery.of(context).size.width*0.7,
              decoration: BoxDecoration(
                color: Colors.white10,
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                separatorBuilder: (context, index) => SizedBox(height: 10,),
                itemBuilder: (context, index){
                  return Container(
                    height: MediaQuery.of(context).size.height*0.015,
                    width: MediaQuery.of(context).size.width*0.9,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
          :

      Center(child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            mediaType=="image" ?
            InkWell(
              onTap: (){
                /*
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: true, // set to false
                        pageBuilder: (_, __, ___) => PictureView(imageURL: imageURL, title: imageTitle,)),
                      );

                     */
                Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: imageURL, title: contentTitle, index: -1,)));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Hero(
                  tag: "tag${-1}",
                  child: Image(image: CachedNetworkImageProvider(imageURL),),

                  /*FadeInImage.assetNetwork(
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
            )
                :
            YoutubePlayerBuilder(
              player: YoutubePlayer(
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
              builder: (context, player){
                return Column(
                  children: [
                    player,
                  ],
                );
              },
            ),
            SizedBox(height: 5,),
            Expanded(
              child: Center(
                child: ListView(
                  children: [
                    Center(child: Text(contentTitle, style: TextStyle(fontSize: 20),)),
                    SizedBox(height: 10,),
                    Text(contentDescription, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
                    Text(contentDate),
                    contentCopyRight==null ? Container() : Center(child: Text(contentCopyRight)),
                  ],
                ),
              ),
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
      ),),

    );
  }
}

class PictureView extends StatelessWidget {
  String imageURL, title;
  int index;
  PictureView({Key key, @required this.imageURL, @required this.title, @required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Container(
            child: Hero(
              tag: "tag$index",
              child: PhotoView(
                imageProvider: NetworkImage(imageURL),
              ),
            )
        ),
      ),
    );
  }
}

