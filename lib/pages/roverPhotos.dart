import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:universum_app/helpers/ad_helper.dart';
import 'package:universum_app/pages/apod.dart';

List<String> roverNames = ['Curiosity', 'Perseverance', 'Opportunity', 'Spirit'];
List<String> roverImages = ['assets/Curiosity.jpg', 'assets/Perseverance.jpg', 'assets/Opportunity.jpg', 'assets/Spirit.jpg'];
List<String> activeDays = ['06/08/2012 - Current', '18/02/2021 - Current', '26/01/2004 - 09/06/2018', '05/01/2004 - 21/03/2010'];

class roverSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select a Rover"),
      ),
      body: Center(
        child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            childAspectRatio: 0.7,
            children: List.generate(roverNames.length, (index) {
            return InkWell(
              onTap: () {
                String date;
                roverNames[index]=="Curiosity" || roverNames[index]=="Perseverance"? date="Active" : roverNames[index]=="Opportunity"? date="2004-01-26" : date="2004-01-05";
                Navigator.push(context, MaterialPageRoute(builder: (context) => roverPhotos(roverName: roverNames[index], lastActiveDay: date, activeDays: activeDays[index])));
                },
              child: Center(
                child: Container(
                  height: 400,
                  //height: MediaQuery.of(context).size.height*0.8,
                  width: MediaQuery.of(context).size.width*0.45,
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Text(roverNames[index], style: TextStyle(color: Colors.white, fontSize: 25),)),
                      Text("Active Dates: ${activeDays[index]}", style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center,),
                    ],
                  )),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: AssetImage(roverImages[index]),
                    ),
                  ),

                  /*
                  child: Stack(
                    children: [
                      FittedBox(
                          child: Image(image: AssetImage(roverImages[index]),
                            fit: BoxFit.fill,
                          )),
                      Text(roverNames[index]),
                    ],
                  ),
                  */
                ),
              ),
            );
          })
        ),
      ),
    );
  }
}


class photoDetails{
  int sol, photoID, cameraID, roverID;
  String cameraName, cameraFullName, imgURL;
  String roverName, roverStatus, earthDate;

  photoDetails({this.sol, this.photoID, this.cameraID, this.cameraName, this.cameraFullName, this.imgURL, this.roverID, this.roverName,
    this.roverStatus, this.earthDate});
}

class roverPhotos extends StatefulWidget {

  String roverName, lastActiveDay, activeDays;
  roverPhotos({Key key, @required this.roverName, @required this.lastActiveDay, @required this.activeDays}) : super(key: key);

  @override
  _roverPhotosState createState() => _roverPhotosState();
}

class _roverPhotosState extends State<roverPhotos> {

  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  List<photoDetails> photosList = [];
  List<photoDetails> filteredPhotosList=[];
  List<List> finalList = [[]];

  bool _loading=false;
  bool _showPics = false;

  bool expanded = true;

  int _index=0;
  bool _visible=false;

  String roverCameraName = "FHAZ";

  List<String> roverCameraNames = [];

  List<int> indexSelected;

  DateTime selectedDate;
  var formatter = new DateFormat('yyyy-MM-dd');

  int statusCode;

  Future<void> getPhotos(String rover) async {
    print("In getPhotos");
    setState(() {
      _loading=true;
    });
    photoDetails item;
    String formattedDate = formatter.format(selectedDate);
    String url = "https://api.nasa.gov/mars-photos/api/v1/rovers/$rover/photos?earth_date=$formattedDate&api_key=DEMO_KEY";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    statusCode=response.statusCode;

    if(statusCode==200) {
      if (jsonData['photos'].isEmpty) {
        print("Empty");
        Fluttertoast.showToast(
            msg: "",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.black,
            fontSize: 16.0
        );
        setState(() {
          _loading = false;
        });
      }

      else {
        photosList.clear();
        finalList.clear();
        roverCameraNames.clear();
        for (var elements in jsonData['photos']) {
          /*
      print(elements['id'].runtimeType);
      print(elements['sol'].runtimeType);
      print(elements['earth_date'].runtimeType);
      print(elements['id'].runtimeType);

       */
          //numRoverCameras = elements['camera']['name'].length();
          if (!roverCameraNames.contains(elements['camera']['full_name']))
            roverCameraNames.add(elements['camera']['full_name']);
          //print(roverCameraNames);


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

        finalList.clear();
        finalList = List<List>.generate(roverCameraNames.length, (index) => []);
        indexSelected =
        List<int>.generate(roverCameraNames.length, (int index) => 0);
        for (int i = 0; i < photosList.length; ++i)
          for (int j = 0; j < roverCameraNames.length; ++j)
            if (photosList[i].cameraFullName == roverCameraNames[j])
              finalList[j].add(photosList[i]);

        await Future.wait(
          photosList.map((item) => cacheImage(context, item.imgURL)).toList(),
        );

        setState(() {
          _loading = false;
          _visible = true;
        });
      }
    }
    setState(() {
      _loading=false;
    });
  }

  Future cacheImage(BuildContext context, String imageURL) => precacheImage(
      CachedNetworkImageProvider(imageURL), context);

  /*
  void filterList(String roverCameraName) {
    filteredPhotosList = [];
    for(var i in photosList){
      if(i.cameraName == roverCameraName)
        filteredPhotosList.add(i);
    }

  }

   */

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
    if(widget.lastActiveDay=="Active")
      selectedDate = DateTime.now().subtract(Duration(days: 3));
    else
      selectedDate = DateTime.parse(widget.lastActiveDay);
    getPhotos(widget.roverName);
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Rover Images"),
            Text(formatter.format(selectedDate), style: TextStyle(fontSize: 18),),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.date_range),
              onPressed: () async {
                final DateTime picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate, // Refer step 1
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if(picked!=null) {
                  if (picked != null && picked != selectedDate &&
                      picked.isBefore(
                          DateTime.now().subtract(Duration(days: 2))))
                    setState(() {
                      selectedDate = picked;
                      getPhotos(widget.roverName);
                    });
                  else if (picked.isAfter(
                      DateTime.now().subtract(Duration(days: 2))))
                    Fluttertoast.showToast(
                        msg: "No pictures available for this day",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        fontSize: 16.0
                    );
                }
              })
        ],
      ),
      body: _loading? Center(child: Column(
        children: [
          Image(image: AssetImage("assets/Rover.gif")),
          Text("Loading Rover Images.."),
        ],
      ),) : statusCode==429? Center(child: Text("Too many requests! Try again in some time"),) :
          roverCameraNames.length==0 ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.roverName + " Rover"),
              Text("Active Days: " + widget.activeDays),
              Text("Couldn't find any pictures for this day"),
            ],
          )) :
      Column(
        children: [
          Column(
            children: [
              Text(widget.roverName + " Rover"),
              Text("Active Days: " + widget.activeDays),
              Text("Sol: " + finalList[0][0].sol.toString(), style: TextStyle(fontSize: 20),),
            ],
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: roverCameraNames.length,
                itemBuilder: (context, index){
                //return _returnList(index);
                  return Column(
                    children: [
                      Text(roverCameraNames[index], style: TextStyle(fontSize: 20),),
                      Container(
                        height: 300,
                        child: ListView.builder(
                          itemCount: finalList[index].length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i){
                              return InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: finalList[index][i].imgURL, title: "Photo ID: ${finalList[index][i].photoID}", index: -1,))),
                                child: Card(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Hero(
                                      tag: "tag${index+1}$i",
                                      child: finalList[index][i].imgURL!=null? Image(image: CachedNetworkImageProvider(finalList[index][i].imgURL)) : Text("Empty"),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
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


  /*
  Future<List<CachedNetworkImageProvider>> _loadAllImages() async{
    List<CachedNetworkImageProvider> cachedImages = [];
    for(int i=0;i<filteredPhotosList.length;i++) {
      var configuration = createLocalImageConfiguration(context);
      cachedImages.add(new CachedNetworkImageProvider("${filteredPhotosList[i].imgURL}")..resolve(configuration));
    }
    return cachedImages;
  }

   */
   

  Widget _returnList(int pos) {
    //print("In _returnList");
    filteredPhotosList.clear();
    for(var i in photosList) {
      if (i.cameraFullName == roverCameraNames[pos])
        filteredPhotosList.add(i);
    }
    return Column(
      children: [
        Text(roverCameraNames[pos]),
        Container(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filteredPhotosList.length,
              itemBuilder: (context, i){
                return Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Hero(
                      tag: "tag${pos+1}$i",
                      child: Image(image: NetworkImage(filteredPhotosList[i].imgURL)),

                    ),
                  ),
                );
              }),
        ),
      ],
    );
    /*
    return Column(
            children: [
              Text(roverCameraNames[pos]),
              FutureBuilder(
                future: _loadAllImages(),
                builder: (context, snapshot) {
                  return AnimatedContainer(
                    duration: Duration(seconds: 1),
                    height: 300, // card height
                    child: PageView.builder(
                      itemCount: filteredPhotosList.length,
                      scrollDirection: Axis.horizontal,
                      controller: PageController(
                          initialPage: 0, keepPage: true, viewportFraction: 0.8),
                      onPageChanged: (int index) {
                        setState(() {
                          indexSelected[pos] = index;
                        });
                      },
                      itemBuilder: (_, i) {
                        ImageProvider image = snapshot.data[i];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              //expanded = !expanded;
                              print((pos+1)*10+i);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: filteredPhotosList[i].imgURL, title: roverCameraNames[pos], index: (pos+1)*10+i,)));
                            });
                          },
                          child: Transform.scale(
                            scale: i == indexSelected[pos] ? 1 : 0.90,
                            child:
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Hero(
                                  tag: "tag${pos+1}$i",
                                  child: Image(image: image,),

                                ),
                              ),
                            ),

                          ),
                        );
                      },
                    ),


                  );
                }
              ),

              Divider(),
            ],
          );
    */

  }
}

