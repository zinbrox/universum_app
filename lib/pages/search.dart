import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:universum_app/helpers/ad_helper.dart';

class Items {
  String imageURL; // image data
  String center, media_type, description, title;
  DateTime date;
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

  BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  List<Items> searchList = [];
  final TextEditingController _searchText = new TextEditingController();

  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

  bool _loading=true;
  int _index=0;
  bool expanded=false;

  Future<void> getSearch(String text) async {
    print("In getSearch()");
    Items item;
    String url="https://images-api.nasa.gov/search?q=$text";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);


    for(var elements in jsonData['collection']['items']) {
        item = Items(
          imageURL: elements['links'][0]['href'],
          center: elements['data'][0]['center'],
          media_type: elements['data'][0]['media_type'],
          description: elements['data'][0]['description'],
          title: elements['data'][0]['title'],
          date: DateTime.parse(elements['data'][0]['date_created']),
          keywords: elements['data'][0]['keywords'],
        );
        searchList.add(item);
    }
    searchList.sort((b,a) => a.date.compareTo(b.date));

    await Future.wait(
      searchList.map((item) => cacheImage(context, item.imageURL)).toList(),
    );

    setState(() {
      _loading=false;
    });
  }

  Future cacheImage(BuildContext context, String imageURL) => precacheImage(
      CachedNetworkImageProvider(imageURL), context);

  void initialiseBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
      ),
    );

    _bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    initialiseBanner();
    getSearch(widget.keyword);
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results for \"${widget.keyword}\""),
        centerTitle: true,
      ),
      body: _loading? Center(child: CircularProgressIndicator(),) : Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: searchList.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemBuilder: (context, index){
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleView(item: searchList[index], imageURL: searchList[index].imageURL,))),
                    child: Container(
                      child: Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Image(image: CachedNetworkImageProvider(searchList[index].imageURL),),
                            Text(searchList[index].title, style: TextStyle(fontSize: 20),),
                            SizedBox(height: 10,),
                            Text(searchList[index].description, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                            SizedBox(height: 5,),
                            Text(dateFormatter.format(searchList[index].date)),
                            Text("Center: " + searchList[index].center),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ),
                    ),
                  );
                  }),
            ),
            _isBannerAdReady ?
            Container(
              alignment: Alignment.bottomCenter,
              //height: 100,
              //width: MediaQuery.of(context).size.width*0.4,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ) : Container(),
          ],
        ),
      ),
    );
  }


}

class ArticleView extends StatelessWidget {
  Items item;
  String imageURL;
  ArticleView({Key key, @required this.item, @required this.imageURL}) : super(key: key);

  final DateFormat dateFormatter = DateFormat('dd-MM-yyyy');

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.5,
                            child: Text(item.title, style: TextStyle(fontSize: 20),)),
                        Expanded(child: Text("Date: " + dateFormatter.format(item.date), style: TextStyle(fontSize: 20), textAlign: TextAlign.right,)),
                      ],
                    ),
                    Text("Center: " + item.center, style: TextStyle(fontSize: 15),),
                    SizedBox(height: 10,),
                    Text(item.description, style: TextStyle(fontSize: 18), textAlign: TextAlign.center,),
                    Text("Keywords: " + item.keywords.toString(), textAlign: TextAlign.center,),
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


