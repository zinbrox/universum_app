import 'package:flutter/material.dart';
import 'package:universum_app/pages/search.dart';

List<String> titles = ["Picture of the Day", "ISS Tracker", "Mars Rover Photos", "Upcoming Launches"];
List<String> images = ["assets/OrionNebula.jpg", "assets/ISS.jpg", "assets/Curiosity.jpg", "assets/RocketLaunch.jpg"];
List<String> links = ['/apod', '/issLoc', '/roverSelect', '/upcomingLaunches'];

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with AutomaticKeepAliveClientMixin<ExplorePage>, WidgetsBindingObserver{
  @override
  bool get wantKeepAlive => true;

  final FocusNode inputFocusNode = FocusNode();

  final TextEditingController _searchText = new TextEditingController();
  bool _loading=true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if (value == 0) {
      inputFocusNode.unfocus();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    cacheImages();
  }

  Future<void> cacheImages() async {
    await Future.wait(
      images.map((image) => cacheImage(context, image)).toList(),
    );
    setState(() {
      _loading=false;
    });
  }

  Future cacheImage(BuildContext context, String image) => precacheImage(AssetImage(image), context);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore"),
      ),
      body: _loading? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage("assets/RocketLoading.gif")),
          ])) :
      Center(child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              focusNode: inputFocusNode,
              //keyboardType: TextInputType.multiline,
              controller: _searchText,
              onSubmitted: (String text){
                FocusScope.of(context).unfocus();
                Navigator.push(context, MaterialPageRoute(builder: (context) => NASASearch(keyword: text)));
              },
              decoration: InputDecoration(
                  //contentPadding: EdgeInsets.all(20.0),
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.navigate_next),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => NASASearch(keyword: _searchText.text)));
                    },
                  ),
                  hintText: "Search NASA's Library"
              ),
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
                children: List.generate(titles.length, (index) {
                  return InkWell(
                    onTap: () => Navigator.pushNamed(context, links[index]),
                    child: Center(
                      child: Container(
                        height: 400,
                        //height: MediaQuery.of(context).size.height*0.8,
                        width: MediaQuery.of(context).size.width*0.45,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                          color: Colors.black12,
                            child: Text(titles[index], style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.center,)),),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          /*
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                           */
                          image: DecorationImage(
                            fit: BoxFit.fitHeight,
                            image: AssetImage(images[index]),
                          ),
                        ),
                      ),
                    ),
                  );
                })
            ),
          ),
        ],
      ),
          /*
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            //controller: _searchText,
            decoration: InputDecoration(
                filled: true,
                //fillColor: Colors.grey,
                //border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                /*
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      //searchList.clear();
                    });
                    //getSearch(_searchText.text);
                    FocusScope.of(context).unfocus();
                  },
                ),
                */
                hintText: "Search"
            ),
          ),
          Text("Hello"),
          ElevatedButton(
            child: Text("APOD"),
            onPressed: (){
              Navigator.pushNamed(context, '/apod');
            },
          ),
          ElevatedButton(
            child: Text("Weather"),
            onPressed: (){
              Navigator.pushNamed(context, '/marsWeather');
            },
          ),
          ElevatedButton(
            child: Text("Search"),
            onPressed: (){
              Navigator.pushNamed(context, '/search');
            },
          ),
          ElevatedButton(
            child: Text("Rover Photos"),
            onPressed: (){
              Navigator.pushNamed(context, '/roverSelect');
            },
          ),
          ElevatedButton(
            child: Text("ISS Location"),
            onPressed: (){
              Navigator.pushNamed(context, '/issLoc');
            },
          ),
          ElevatedButton(
            child: Text("Settings"),
            onPressed: (){
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ElevatedButton(
            child: Text("Upcoming Launches"),
            onPressed: (){
              Navigator.pushNamed(context, '/upcomingLaunches');
            },
          ),
          /*
          ElevatedButton(
              onPressed: (){
                print("Started");
                AndroidAlarmManager.periodic(const Duration(seconds: 10), 0, showPrint);
              },
              child: Text("Alarm Manager")),
          ElevatedButton(onPressed: (){
            print("Cancelled");
            AndroidAlarmManager.cancel(0);
            localNotifyManager.cancelAllNotification();

          }, child: Text("Cancel Notifications"))
           */
          Spacer(),
        ],
      )
          */
      ),
    );
  }
}
