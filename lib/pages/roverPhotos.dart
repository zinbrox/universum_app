import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:universum_app/pages/apod.dart';

List<String> roverNames = ['Curiosity', 'Perseverance', 'Opportunity', 'Spirit'];
List<String> roverImages = ['assets/CuriosityMobile.jpg', 'assets/CuriosityMobile.jpg', 'assets/CuriosityMobile.jpg', 'assets/CuriosityMobile.jpg'];
List<String> activeDates = [];

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
            mainAxisSpacing: 8.0,
            children: List.generate(roverNames.length, (index) {
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => roverPhotos(roverName: roverNames[index]))),
              child: Center(
                child: Container(
                  child: Stack(
                    children: [
                      Image(image: AssetImage(roverImages[index]),),
                      Text(roverNames[index]),
                    ],
                  ),
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

  String roverName;
  roverPhotos({Key key, @required this.roverName}) : super(key: key);

  @override
  _roverPhotosState createState() => _roverPhotosState();
}

class _roverPhotosState extends State<roverPhotos> {


  List<photoDetails> photosList = [];
  List<photoDetails> filteredPhotosList=[];

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

    if(jsonData['photos'].isEmpty) {
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
        _loading=false;
      });
    }

    else {
      photosList.clear();
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
      //filteredPhotosList = photosList;
      indexSelected =
      List<int>.generate(roverCameraNames.length, (int index) => 0);
      setState(() {
        _loading = false;
        _visible = true;
      });
    }
  }

  /*
  void filterList(String roverCameraName) {
    filteredPhotosList = [];
    for(var i in photosList){
      if(i.cameraName == roverCameraName)
        filteredPhotosList.add(i);
    }

  }

   */

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().subtract(Duration(days: 2));
    getPhotos(widget.roverName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Mars Rovers"),
            Text(formatter.format(selectedDate)),
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
                if (picked != null && picked != selectedDate && picked.isBefore(DateTime.now().subtract(Duration(days: 2))))
                  setState(() {
                    selectedDate = picked;
                    getPhotos(widget.roverName);
                  });
                else if(picked.isAfter(DateTime.now().subtract(Duration(days: 2))))
                  Fluttertoast.showToast(
                      msg: "No pictures available for this day",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                      fontSize: 16.0
                  );
              })
        ],
      ),
      body: _loading? CircularProgressIndicator() :
          roverCameraNames.length==0 ? Text("Empty") :
      GestureDetector(
        onTap: (){
          setState(() {
            _visible=false;
          });
        },
        child: ListView.builder(
          itemCount: roverCameraNames.length,
            itemBuilder: (context, index){
            return _returnList(index);
            }),
        /*
        Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    _visible ? Center(
                      child: ClipRect(  // <-- clips to the 200x200 [Container] below
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 5.0,
                            sigmaY: 5.0,
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text('Hello World'),
                          ),
                        ),
                      ),
                    ) : Container(),
                    Visibility(
                      visible: _visible,
                      maintainState: false,
                      child: Center(
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          height: 300, // card height
                          child: PageView.builder(
                                    itemCount: filteredPhotosList.length,
                                    scrollDirection: Axis.horizontal,
                                    controller: PageController(
                                        initialPage: 0, keepPage: true, viewportFraction: 0.6),
                                    onPageChanged: (int index) {
                                      setState(() {
                                        _index=index;
                                      });
                                    },
                                    itemBuilder: (_, i) {
                                      return GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            expanded = !expanded;
                                          });
                                        },
                                        child: Transform.scale(
                                          scale: i == _index ? 1 : 0.90,
                                          child:
                                          Card(
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: <Widget>[
                                                  Image.network(filteredPhotosList[i].imgURL, height: 300,),
                                                  Text(filteredPhotosList[i].roverName),
                                                  Text(filteredPhotosList[i].cameraFullName,),
                                                  Text('Sol ' + filteredPhotosList[i].sol.toString()),
                                                  Text('Earth Date: ' + filteredPhotosList[i].earthDate),
                                                  //Text(searchList[index].media_type.toString()),
                                                ],
                                              ),
                                            ),
                                          ),

                                        ),
                                      );
                                    },
                                  ),


                          ),
                        ),
                    ),
                  ],

                ),
              ),
              /*
              Expanded(
                child: ListView.builder(
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
                      }),
                ),
              */
            ],
          ),
        ),
        */
      )
    );
  }


  Future<List<CachedNetworkImageProvider>> _loadAllImages() async{
    List<CachedNetworkImageProvider> cachedImages = [];
    for(int i=0;i<filteredPhotosList.length;i++) {
      var configuration = createLocalImageConfiguration(context);
      cachedImages.add(new CachedNetworkImageProvider("${filteredPhotosList[i].imgURL}")..resolve(configuration));
    }
    return cachedImages;
  }
   

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

  }
}


/*
_loading ? Center(
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
 */