import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
                  child: Image(image: AssetImage(roverImages[index]),),
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

  Future<void> getPhotos(String rover) async {
    print("In getPhotos");
    photoDetails item;
    String url = "https://api.nasa.gov/mars-photos/api/v1/rovers/$rover/photos?earth_date=2021-03-30&api_key=DEMO_KEY";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    for(var elements in jsonData['photos']){
      /*
      print(elements['id'].runtimeType);
      print(elements['sol'].runtimeType);
      print(elements['earth_date'].runtimeType);
      print(elements['id'].runtimeType);

       */
      //numRoverCameras = elements['camera']['name'].length();
      if(!roverCameraNames.contains(elements['camera']['full_name']))
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

    setState(() {
      _loading=false;
      _visible=true;
    });
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
    getPhotos(widget.roverName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mars Rovers"),
      ),
      body: GestureDetector(
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

  /*
  Future<List<CachedNetworkImageProvider>> _loadAllImages() async{
    List<CachedNetworkImageProvider> cachedImages = [];
    for(int i=0;i<photosList.length;i++) {
      var configuration = createLocalImageConfiguration(context);
      cachedImages.add(new CachedNetworkImageProvider("${photosList[i].imgURL}")..resolve(configuration));
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
              AnimatedContainer(
                duration: Duration(seconds: 1),
                height: 300, // card height
                child: PageView.builder(
                  itemCount: filteredPhotosList.length,
                  scrollDirection: Axis.horizontal,
                  controller: PageController(
                      initialPage: 0, keepPage: true, viewportFraction: 0.8),
                  onPageChanged: (int index) {
                    setState(() {
                      _index = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      onTap: () {
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
                                Image.network(
                                  filteredPhotosList[i].imgURL, height: 300,),
                                /*
                              Text(filteredPhotosList[i].roverName),
                              Text(filteredPhotosList[i].cameraFullName,),
                              Text('Sol ' + filteredPhotosList[i].sol.toString()),
                              Text('Earth Date: ' + filteredPhotosList[i].earthDate),
                              //Text(searchList[index].media_type.toString()),

                               */
                              ],
                            ),
                          ),
                        ),

                      ),
                    );
                  },
                ),


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