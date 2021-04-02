import 'dart:convert';
import 'dart:ui';

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

  bool _loading=false;
  bool _showPics = false;

  bool expanded = true;

  int _index=0;
  bool _visible=false;

  Future<void> getPhotos(String rover) async {
    print("In getPhotos");
    photoDetails item;
    String url = "https://api.nasa.gov/mars-photos/api/v1/rovers/$rover/photos?earth_date=2021-03-30&api_key=DEMO_KEY";
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
    //getPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mars Rovers"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: (){
                    print("Curiosity Selected");
                    getPhotos("Curiosity");
                  },
                    child: Container(child: Text("Curiosity"),)),
                GestureDetector(
                    onTap: (){
                      print("Opportunity Selected");
                      getPhotos("Opportunity");
                    },
                    child: Container(child: Text("Opportunity"),)),
                GestureDetector(
                    onTap: (){
                      print("Spirit Selected");
                      getPhotos("Spirit");
                    },
                    child: Container(child: Text("Spirit"),)),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                      child: Image(image: AssetImage("assets/CuriosityMobile.jpg"))),
                  _loading ? Container() :
                      Positioned(
                        bottom: 0,
                        right: 50,
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              expanded=!expanded;
                              _visible=!_visible;
                            });
                          },
                          child: Transform.scale(
                            scale: expanded? 1 : 2,
                            child: Card(
                              child: Text("FHAZ Photos"),
                            ),
                          ),
                        ),
                      ),
                  _loading ? Container() :
                  Positioned(
                    top: 0,
                    right: 50,
                    child: ElevatedButton(
                      onPressed: (){
                        _showPics=!_showPics;

                      },
                      child: Text("Rear Hazard Avoidance Camera Photos"),
                    ),
                  ),
                  _loading ? Container() :
                  Positioned(
                    top: 75,
                    left: 0,
                    child: ElevatedButton(
                      onPressed: (){
                        _showPics=!_showPics;

                      },
                      child: Text("Chemistry and Camera Complex Photos"),
                    ),
                  ),
                  _loading ? Container() :
                  Positioned(
                    top: 75,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: (){
                        _showPics=!_showPics;

                      },
                      child: Text("Navigation Camera Photos"),
                    ),
                  ),
                  _loading ? Container() :
                  Positioned(
                    top: 75,
                    left: 75,
                    child: ElevatedButton(
                      onPressed: (){
                        _showPics=!_showPics;

                      },
                      child: Text("Navigation Camera Photos"),
                    ),
                  ),
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
                  ) : null,
                  Visibility(
                    visible: _visible,
                    maintainState: false,
                    child: Center(
                      child: AnimatedContainer(
                        duration: Duration(seconds: 1),
                        height: expanded ? 800 : 400, // card height
                        child: PageView.builder(
                                  itemCount: photosList.length,
                                  controller: PageController(
                                      initialPage: 1, keepPage: true, viewportFraction: 0.8),
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
                                                Image.network(photosList[i].imgURL, height: 300,),
                                                Text(photosList[i].roverName),
                                                Text(photosList[i].cameraFullName,),
                                                Text('Sol ' + photosList[i].sol.toString()),
                                                Text('Earth Date: ' + photosList[i].earthDate),
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
      )
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