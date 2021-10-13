import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:universum_app/helpers/ad_helper.dart';
import 'package:universum_app/styles/color_styles.dart';
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
  String imageURL, smallImageURL, contentTitle, contentDescription, contentCopyRight, contentDate;
  String videoURL;
  int statusCode;
  String statusMessage;




  Future<void> getAPOD() async {
    print("in getAPOD");
    String url;
    url = "https://api.nasa.gov/planetary/apod?api_key=//YOUR-API-KEY-HERE";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    statusCode = response.statusCode;
    if(statusCode == 429) {
      url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY";
      response = await http.get(Uri.parse(url));
      jsonData = jsonDecode(response.body);
      statusCode = response.statusCode;
    }
    statusMessage = response.reasonPhrase;
    if(statusCode == 200) {
      mediaType = jsonData['media_type'];
      if (mediaType == "image") {
        imageURL = jsonData['hdurl'];
        smallImageURL = jsonData['url'];
        //precacheImage(CachedNetworkImageProvider(imageURL), context);
        await precacheImage(CachedNetworkImageProvider(smallImageURL), context);
      }
      else {
        videoURL = jsonData['url'];
      }

      contentTitle = jsonData['title'];
      contentDescription = jsonData['explanation'];
      contentCopyRight = jsonData['copyright'];
      contentDate = jsonData['date'];
    }

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
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Astronomical Picture of the Day"),
        centerTitle: true,
      ),
      body: _loading ?
      // Shimmer Loading Effect
      Shimmer.fromColors(
        baseColor: isDark? Colors.grey[350] : Colors.grey[300],
        highlightColor: isDark? Colors.white : Colors.grey[500],
        enabled: _loading,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.4,
              width: MediaQuery.of(context).size.width*0.9,
              decoration: BoxDecoration(
                color: isDark? Colors.white10 : Colors.grey,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              height: MediaQuery.of(context).size.height*0.025,
              width: MediaQuery.of(context).size.width*0.7,
              decoration: BoxDecoration(
                color: isDark? Colors.white10 : Colors.grey,
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: ListView.separated(
                itemCount: 12,
                separatorBuilder: (context, index) => SizedBox(height: 10,),
                itemBuilder: (context, index){
                  return Container(
                    height: MediaQuery.of(context).size.height*0.015,
                    width: MediaQuery.of(context).size.width*0.9,
                    decoration: BoxDecoration(
                      color: isDark? Colors.white10 : Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
          : statusCode==429? Center(child: Text("Too Many Requests! Try again in some time")) : statusCode!=200? Center(child: Column(
            children: [
              Text("Error Code: $statusCode"),
              Text("Reason Phrase: $statusMessage"),
            ],
          )) :

      Center(child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            mediaType=="image" ?
            FittedBox(
              fit: BoxFit.fitHeight,
              child: Container(
                height: MediaQuery.of(context).size.height*0.5,
                child: InkWell(
                  onTap: (){
                    if(mediaType=="image")
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: imageURL, title: contentTitle, index: -1,)));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Hero(
                      tag: "tag${-1}",
                      //child: Image(image: CachedNetworkImageProvider(imageURL),),

                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CachedNetworkImage(
                            imageUrl: imageURL,
                            progressIndicatorBuilder: (context, url, downloadProgress) => Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height*0.5,
                                  width: MediaQuery.of(context).size.width,
                                  child: ClipRRect(
                                    child: ImageFiltered(
                                      imageFilter: downloadProgress.progress!=null? downloadProgress.progress>0.75? ImageFilter.blur(sigmaX: 3, sigmaY: 3) : downloadProgress.progress>0.4? ImageFilter.blur(sigmaX: 5, sigmaY: 5) : ImageFilter.blur(sigmaX: 8, sigmaY: 8) : ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                                        child: Image(image: CachedNetworkImageProvider(smallImageURL),)),
                                  ),
                                ),
                                CircularProgressIndicator(value: downloadProgress.progress),
                              ],
                            ),
                          ),

                          Align(
                            child: Icon(Icons.touch_app, size: 40,),
                            alignment: Alignment.bottomRight,
                          ),
                        ],
                      ),


                    ),
                  ),
                ),
              ),
            )
                :
            YoutubePlayerBuilder(
              onExitFullScreen: () {
                SystemChrome.setPreferredOrientations(DeviceOrientation.values);
              },
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
              child: SizedBox(
                height: 200,
                child: ListView(
                  children: [
                    Center(child: SelectableText(contentTitle, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,)),
                    SizedBox(height: 10,),
                    SelectableText(contentDescription, textAlign: TextAlign.center, style: TextStyle(fontSize: 15),),
                    SizedBox(height: 10,),
                    Text(contentDate, textAlign: TextAlign.center,),
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

  final Dio dio = Dio();
  File filePathFinal;

  Future<bool> saveImage(String url, String fileName) async {
    Directory directory;
    try {
      if(Platform.isAndroid) {
        if(await _requestPermission(Permission.storage)){
          directory = await getExternalStorageDirectory();
          print(directory.path);
          String newPath = "";
          List<String> folders = directory.path.split("/");
          for(int i=1;i<folders.length;++i){
            if(folders[i]!="Android") {
              newPath += "/"+folders[i];
            }
            else
              break;
          }
          newPath = newPath+"/OrbitFeed";
          directory = Directory(newPath);
        }
        else
          return false;
      }
      // For IOS
      else {
        if(await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        }
        else
          return false;
      }
      // If OrbitFeed folder doesn't exist, create it
      if(!await directory.exists()){
        await directory.create(recursive: true);
      }
      if(await directory.exists()) {
        Fluttertoast.showToast(
            msg: "Downloading Image...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0
        );
        File saveFile = File(directory.path+"/$fileName.png");
        filePathFinal = saveFile;
        await dio.download(url, saveFile.path);

        if(Platform.isIOS){
          await ImageGallerySaver.saveFile(saveFile.path, isReturnPathOfIOS: true);
        }

        Fluttertoast.showToast(
            msg: "Downloaded Image to ${directory.path}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0
        );
        return true;
      }
    } catch(e) {
      print(e);
    }
    return false;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if(await permission.isGranted){
      return true;
    }
    else {
      var result = await permission.request();
      if(result == PermissionStatus.granted) {
        return true;
      }
      else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                    value: 1,child: Text("Download")),
                PopupMenuItem(
                    value: 2,child: Text("Share")),
              ],
            onSelected: (value) async {
                if(value==1) {
                  if(!await saveImage(imageURL, title))
                    Fluttertoast.showToast(
                        msg: "Image couldn't be downloaded",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: isDark? Colors.white : Colors.black,
                        textColor: isDark? Colors.black : Colors.white,
                        fontSize: 16.0
                    );
                }
                if(value==2) {
                  saveImage(imageURL, title);
                  if(await saveImage(imageURL, title)) {
                    if(await filePathFinal.exists())
                      Share.shareFiles([filePathFinal.path], text: title.contains("ID")? "Check out this picture from the Mars rover:\n$title\n\nDownload OrbitFeed, your one stop app for all things spaceflight related: https://tinyurl.com/OrbitFeed" :
                      !title.contains("Article")? "Check out today's Picture of the Day:\n$title\n\nDownload OrbitFeed, your one stop app for all things spaceflight related: https://tinyurl.com/OrbitFeed" :
                      "Check out this Image:\n$title\n\nDownload OrbitFeed, your one stop app for all things spaceflight related: https://tinyurl.com/OrbitFeed");
                  }
                }
            },
          )
        ],
      ),
      body: Center(
        child: Container(
            child: Hero(
              tag: "tag${index}",
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(imageURL),
              ),
            )
        ),
      ),
    );
  }
}

