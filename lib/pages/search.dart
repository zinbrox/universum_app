import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Items {
  String imageURL; // image data
  String center, media_type, description, title, date;
  var keywords;// data
  Items({this.imageURL, this.center, this.media_type, this.description, this.title, this.date, this.keywords});
}

class NASASearch extends StatefulWidget {

  String keyword;
  NASASearch({Key key, @required this.keyword}) : super(key: key);
  @override
  _NASASearchState createState() => _NASASearchState();
}

class _NASASearchState extends State<NASASearch> {
  List<Items> searchList = [];
  final TextEditingController _searchText = new TextEditingController();

  bool _loading=true;
  int _index=0;
  bool expanded=false;

  Future<void> getSearch(String text) async {
    print("In getSearch()");
    Items item;
    String url;
    url = "https://images-api.nasa.gov/search?q=$text";
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
      _loading=false;
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
    getSearch(widget.keyword);
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
      body: _loading? Center(child: CircularProgressIndicator(),) : Center(
        child: ListView.builder(
          itemCount: searchList.length,
            itemBuilder: (context, index){
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleView(item: searchList[index], imageURL: searchList[index].imageURL,))),
              child: Container(
                child: Card(
                  child: Column(
                    children: [
                      Image(image: NetworkImage(searchList[index].imageURL),),
                      Text(searchList[index].title),
                      Text(searchList[index].description, maxLines: 4, overflow: TextOverflow.ellipsis,),
                      Text(searchList[index].date),
                      Text(searchList[index].center),
                    ],
                  ),
                ),
              ),
            );
            }),
      ),
    );
  }


}

class ArticleView extends StatelessWidget {
  Items item;
  String imageURL;
  ArticleView({Key key, @required this.item, @required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Article View"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: imageURL, title: item.title,)));
                },
                child: Hero(
                  tag: item.title,
                    child: Image(image: NetworkImage(imageURL),),
              ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Text(item.title),
                    Text(item.center),
                    Text(item.date),
                    Text(item.description),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PictureView extends StatelessWidget {
  String title, imageURL;
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


