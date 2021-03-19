import 'dart:convert';
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

  Future<void> getSearch() async {
    print("In getSearch()");
    Items item;
    String url;
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
  }
  @override
  void initState() {
    super.initState();
    getSearch();
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
      body: ListView.builder(
          itemCount: searchList.length,
          itemBuilder: (BuildContext context, int index){
            return GestureDetector(
              onTap: (){

              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: <Widget>[
                    Image.network(searchList[index].imageURL),
                    Text(searchList[index].title.toString()),
                    Text(searchList[index].description.toString()),
                    Text(searchList[index].date),
                    Text(searchList[index].keywords.toString()),
                    Text('Center: ' + searchList[index].center.toString()),
                    Text(searchList[index].media_type.toString()),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
