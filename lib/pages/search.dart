import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Items {
  String imageURL; // image data
  String center, media_type, description, title, date;
  var keywords;// data
  Items({this.imageURL, this.center, this.media_type, this.description, this.title, this.date, this.keywords});
}

class NASASearch extends StatefulWidget {
  @override
  _NASASearchState createState() => _NASASearchState();
}

class _NASASearchState extends State<NASASearch> {
  List<Items> searchList = [];
  final TextEditingController _searchText = new TextEditingController();

  int _index=0;
  bool expanded=false;

  Future<void> getSearch(String text) async {
    print("In getSearch()");
    Items item;
    String url;
    if(text!=null)
      url = "https://images-api.nasa.gov/search?q=$text";
    else
      url = "https://images-api.nasa.gov/search?q=pluto";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    for(var elements in jsonData['collection']['items']) {
      //print(elements['data'][0]['title']);
      //var responseLink = await http.get(Uri.parse(elements['href']));
      //var jsonDataLinks = jsonDecode(responseLink.body);
      //print(jsonDataLinks[0]);
      print(elements['links'][0]['href']);
        item = Items(
          imageURL: elements['links'][0]['href'],
          center: elements['data'][0]['center'],
          media_type: elements['data'][0]['media_type'],
          description: elements['data'][0]['description'],
          title: elements['data'][0]['title'],
          date: elements['data'][0]['date_created'],
          keywords: elements['data'][0]['keywords'],
        );
        searchList.add(item);
    }
    setState(() {

    });
  }
  Future<List<CachedNetworkImageProvider>> _loadAllImages() async{
    List<CachedNetworkImageProvider> cachedImages = [];
    for(int i=0;i<searchList.length;i++) {
      var configuration = createLocalImageConfiguration(context);
      cachedImages.add(new CachedNetworkImageProvider("${searchList[i].imageURL}")..resolve(configuration));
    }
    return cachedImages;
  }

  @override
  void initState() {
    super.initState();
    getSearch("");
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NASA Image And Video Library Search"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              height: expanded ? 800 : 500, // card height
              child: FutureBuilder(
                future: _loadAllImages(),
                builder: (context, snapshot) {
                  if(snapshot.hasData) {
                    return PageView.builder(
                      itemCount: searchList.length,
                      controller: PageController(
                          initialPage: 1, keepPage: true, viewportFraction: 0.85),
                      onPageChanged: (int index) {
                        setState(() {
                          _index=index;
                        });
                      },
                      itemBuilder: (_, i) {
                        ImageProvider image = snapshot.data[i];
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleView(item: searchList[i], image: image)));
                            /*
                            setState(() {
                              expanded = !expanded;
                            });
                            
                             */
                          },
                          child: Transform.scale(
                            scale: i == _index ? 0.95 : 0.9,
                            child:
                            Card(
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                  Hero(
                                    tag: searchList[i].title,
                                      child: Image(image: image)),
                                    //Image.network(searchList[_index].imageURL, height: 300,),
                                    Text(searchList[i].title.toString()),
                                    Text(searchList[i].description.toString(), overflow: TextOverflow.ellipsis, maxLines: expanded ? 50 : 4,),
                                    Text(searchList[i].date),
                                    Text(searchList[i].keywords.toString()),
                                    Text('Center: ' +
                                        searchList[i].center.toString()),
                                    //Text(searchList[index].media_type.toString()),
                                  ],
                                ),
                              ),
                            ),

                          ),
                        );
                      },
                    );
                  }else return new Center(child: CupertinoActivityIndicator());
                }
              ),
            ),
          ),
          TextField(
            controller: _searchText,
            decoration: InputDecoration(
              filled: true,
              //fillColor: Colors.grey,
              //border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  getSearch(_searchText.text);
                },
              ),
              hintText: "Search"
            ),
          ),
        ],
      ),
    );
  }


}

class ArticleView extends StatelessWidget {
  Items item;
  ImageProvider image;
  ArticleView({Key key, @required this.item, @required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Hero(
                tag: item.title,
                  child: Image(image: image,)),
              Text(item.title),
            ],
          ),
        ),
      ),
    );
  }
}


