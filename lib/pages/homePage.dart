import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Article {
  String title, imageURL, summary, newsSite, date;
  Article({this.title, this.imageURL, this.summary, this.newsSite, this.date});
}
class Blog {
  String title, imageURL, summary, newsSite, date;
  Blog({this.title, this.imageURL, this.summary, this.newsSite, this.date});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _loading=true;
  List<Article> articles = [];
  List<Blog> blogs = [];

  Future<void> getArticles() async {
    print("In getArticles");
    Article article;
    String url="https://api.spaceflightnewsapi.net/v3/articles";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    for(var result in jsonData) {
      article = Article(
        title: result['title'],
        imageURL: result['imageUrl'],
        summary: result['summary'],
        newsSite: result['newsSite'],
        date: result['publishedAt'],
      );
      articles.add(article);
    }
    setState(() {
      _loading=false;
    });
  }

  Future<void> getBlogs() async {
    print("In getBlogs");
    String url="https://api.spaceflightnewsapi.net/v3/blogs";
    Blog blog;
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    for(var result in jsonData) {
      blog = Blog(
        title: result['title'],
        imageURL: result['imageURL'],
        summary: result['summary'],
        newsSite: result['newsSite'],
        date: result['publishedAt'],
      );
      blogs.add(blog);
    }
  }

  @override
  void initState() {
    super.initState();
    getArticles();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
      ),
      body: _loading? Center(child: CircularProgressIndicator(),) :
          ListView.builder(
            itemCount: articles.length,
              itemBuilder: (context, index){
              return Container(child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    Image.network(articles[index].imageURL),
                    Text(articles[index].title),
                    Text(articles[index].summary),
                    Text(articles[index].newsSite),
                    Text(articles[index].date),
                  ],
                ),
              ),);
              })
    );
  }
}
