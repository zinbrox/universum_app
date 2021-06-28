import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universum_app/styles/color_styles.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Article {
  String title, imageURL, summary, newsSite, newsURL;
  DateTime date;
  Article({this.title, this.imageURL, this.summary, this.newsSite, this.date, this.newsURL});
}
class Blog {
  String title, imageURL, summary, newsSite, newsURL;
  DateTime date;
  Blog({this.title, this.imageURL, this.summary, this.newsSite, this.date, this.newsURL});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage>{
  @override
  bool get wantKeepAlive => true;

  var firebaseUser = FirebaseAuth.instance.currentUser;

  bool _articlesLoading=true, _blogsLoading=true;
  String dropdownValue="Articles";
  List<Article> articles = [];
  List<Blog> blogs = [];

  int statusCodeArticles, statusCodeBlogs;

  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

  Future<void> getArticles() async {
    print("In getArticles");
    Article article;
    String url="https://api.spaceflightnewsapi.net/v3/articles";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    statusCodeArticles=response.statusCode;

    if(statusCodeArticles==200) {
      for (var result in jsonData) {
        article = Article(
          title: result['title'],
          imageURL: result['imageUrl'],
          summary: result['summary'],
          newsSite: result['newsSite'],
          newsURL: result['url'],
          date: DateTime.parse(result['publishedAt']),
        );
        articles.add(article);
      }
    }
    /*
    await Future.wait(
      articles.map((item) => cacheImage(context, item.imageURL)).toList(),
    );

     */
    setState(() {
      _articlesLoading=false;
    });
  }

  Future cacheImage(BuildContext context, String imageURL) => precacheImage(
      CachedNetworkImageProvider(imageURL), context);

  Future<void> getBlogs() async {
    print("In getBlogs");
    String url="https://api.spaceflightnewsapi.net/v3/blogs";
    Blog blog;
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    statusCodeBlogs=response.statusCode;
    if(statusCodeBlogs==200) {
      for (var result in jsonData) {
        blog = Blog(
          title: result['title'],
          imageURL: result['imageUrl'],
          summary: result['summary'],
          newsSite: result['newsSite'],
          newsURL: result['url'],
          date: DateTime.parse(result['publishedAt']),
        );
        blogs.add(blog);
      }
    }
    await Future.wait(
      blogs.map((item) => cacheImage(context, item.imageURL)).toList(),
    );
    setState(() {
      _blogsLoading=false;
    });
  }

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
        msg: "Welcome Back, " + firebaseUser.displayName,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
    getArticles();
    getBlogs();
  }
  @override
  Widget build(BuildContext context) {
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
        actions: [
          DropdownButton<String>(
            value: dropdownValue,
            underline: Container(),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['Articles', 'Blogs']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 18),),
              );
            }).toList(),
          ),
        ],
      ),
      body:
      (dropdownValue=="Articles" && _articlesLoading==false)?
          statusCodeArticles==429? Center(child: Text("Too many requests! Try again in some time"),) : statusCodeArticles!=200? Center(child: Text("Error. Status Code: $statusCodeArticles"),) :
          ListView.separated(
            itemCount: articles.length,
              separatorBuilder: (context, index) => SizedBox(height: 10,),
              itemBuilder: (context, index){
              return InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewer(url: articles[index].newsURL, title: "Article View",))),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(child: Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          //Image(image: CachedNetworkImageProvider(articles[index].imageURL)),
                          CachedNetworkImage(
                              imageUrl: articles[index].imageURL,
                            progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                          ),
                          Text(articles[index].title, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                          SizedBox(height: 10,),
                          Text(articles[index].summary, style: TextStyle(fontSize: 15, color: isDark? Colors.white70 : Colors.black), textAlign: TextAlign.center,),
                          SizedBox(height: 5,),
                          Text("Source: " + articles[index].newsSite),
                          Text(dateFormatter.format(articles[index].date)),
                        ],
                      ),
                    ),),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        child: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 1, child: Text("Share"),)
                          ],
                          onSelected: (value){
                            if(value==1)
                              Share.share('Check out this article: ${articles[index].title}.\nLink: ${articles[index].newsURL}\nDownload OrbitFeed: ');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
              }) :
      (dropdownValue=="Blogs" && _blogsLoading==false)?
      statusCodeBlogs==429? Center(child: Text("Too many requests! Try again in some time"),) : statusCodeBlogs!=200? Center(child: Text("Error. Status Code: $statusCodeBlogs"),) :
      ListView.separated(
          itemCount: blogs.length,
          separatorBuilder: (context, index) => SizedBox(height: 10,),
          itemBuilder: (context, index){
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewer(url: articles[index].newsURL, title: "Article View",))),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(child: Card(
                    elevation: 5,
                    child: Column(
                      children: [
                        //Image(image: CachedNetworkImageProvider(articles[index].imageURL)),
                        CachedNetworkImage(
                          imageUrl: blogs[index].imageURL,
                          progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                        ),
                        Text(blogs[index].title, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                        SizedBox(height: 10,),
                        Text(blogs[index].summary, style: TextStyle(fontSize: 15, color: isDark? Colors.white70 : Colors.black), textAlign: TextAlign.center,),
                        SizedBox(height: 5,),
                        Text("Source: " + blogs[index].newsSite),
                        Text(dateFormatter.format(blogs[index].date)),
                      ],
                    ),
                  ),),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      child: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 1, child: Text("Share"),)
                        ],
                        onSelected: (value){
                          if(value==1)
                            Share.share('Check out this blog: ${blogs[index].title}.\nLink: ${blogs[index].newsURL}\nDownload OrbitFeed: ');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }) :
          Center(child: Image(image: AssetImage("assets/RocketLoading.gif"))),
    );
  }
}

class WebViewer extends StatelessWidget {
  String url, title;
  WebViewer({Key key, @required this.url, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(value: 1, child: Text("Share"),)
              ],
            onSelected: (value){
                if(value==1)
                  Share.share('Check this out: $url\nDownload OrbitFeed: ');
            },
          )
        ],
      ),
      body: WebView(
        initialUrl: url,
      ),
    );
  }
}

