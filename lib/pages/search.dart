import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Items {
  //String URL, imageURL, render, rel; // image data
  String center, media_type, description, title, date;
  var keywords;// data
  Items({this.center, this.media_type, this.description, this.title, this.date, this.keywords});
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
      for(var element in elements['data']) {
        //print(element);
        item = Items(
          center: element['center'],
          media_type: element['media_type'],
          description: element['description'],
          title: element['title'],
          date: element['date_created'],
          keywords: element['keywords'],
        );
        searchList.add(item);
      }

    }
  }
  @override
  void initState() {
    super.initState();
    getSearch();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NASA Image And Video Library Search"),
        centerTitle: true,
      ),
      body: Center(child: Text("NASA Search"),),
    );
  }
}
