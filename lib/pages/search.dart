import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:universum_app/helpers/ad_helper.dart';
import 'package:universum_app/pages/apod.dart';
import 'package:universum_app/styles/color_styles.dart';

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
  int statusCode;
  String statusMessage;

  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: Duration(days: 7),
    ),
  );

  Future<void> getSearch(String text) async {
    print("In getSearch()");
    Items item;
    String url="https://images-api.nasa.gov/search?q=$text";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);

    statusCode = response.statusCode;
    statusMessage = response.reasonPhrase;

    print(statusCode);
    String imageURL, center, media_type, description, title, date;
    var keywords;
    for(var elements in jsonData['collection']['items']) {
      imageURL = elements['links']==null? "" : elements['links'][0]['href']!=null? elements['links'][0]['href'] : "";
      center = elements['data']==null? "" : elements['data'][0]['center']!=null? elements['data'][0]['center'] : "";
      media_type = elements['data']==null? "" : elements['data'][0]['media_type']!=null? elements['data'][0]['media_type'] : "";
      description = elements['data']==null? "" : elements['data'][0]['description']!=null? elements['data'][0]['description'] : "";
      title = elements['data']==null? "" : elements['data'][0]['title']!=null? elements['data'][0]['title'] : "";
      date = elements['data']==null? "" : elements['data'][0]['date_created']!=null? elements['data'][0]['date_created'] : "";
      keywords = elements['data']==null? "" : elements['data'][0]['keywords']!=null? elements['data'][0]['keywords'] : "";
      if(media_type == "video")
        continue;
        item = Items(
          imageURL: imageURL,
          center: center,
          media_type: media_type,
          description: description,
          title: title,
          date: DateTime.parse(date),
          keywords: keywords,
        );
        searchList.add(item);
    }
    searchList.sort((b,a) => a.date.compareTo(b.date));

    setState(() {
      _loading=false;
    });
  }

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
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Results for \"${widget.keyword}\""),
        centerTitle: true,
      ),
      body: _loading? Center(child: CircularProgressIndicator(),) :
          searchList.length==0? Center(child: Text("Couldn't find anything for that"),) :
      Center(
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
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
                              CachedNetworkImage(
                                  imageUrl: searchList[index].imageURL,
                                  cacheManager: customCacheManager,
                                  key: UniqueKey(),
                                  errorWidget: (context, url, error) => Container(
                                   child: Icon(Icons.error, color: Colors.red,),),
                                  progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(child: CircularProgressIndicator(value: downloadProgress.progress))),
                              ),
                              Text(searchList[index].title, style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),
                              SizedBox(height: 10,),
                              Text(searchList[index].description, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: isDark? Colors.white70 : Colors.black), textAlign: TextAlign.center,),
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
    final _themeChanger = Provider.of<DarkThemeProvider>(context);
    bool isDark = _themeChanger.darkTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Article View"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              FittedBox(
                fit: BoxFit.fitHeight,
                child: Container(
                  height: MediaQuery.of(context).size.height*0.5,
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PictureView(imageURL: imageURL, title: item.title + " Article", index: -1)));
                    },
                    child: Hero(
                      tag: "tag-1",
                        child: Image(image: NetworkImage(imageURL),),
                  ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    SelectableText(item.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 20),),
                    SizedBox(height: 10,),
                    SelectableText(item.description, style: TextStyle(fontSize: 18, color: isDark? Colors.white70 : Colors.black), textAlign: TextAlign.center,),
                    SizedBox(height: 10,),
                    Text(dateFormatter.format(item.date), textAlign: TextAlign.center,),
                    Text("Center: " + item.center, textAlign: TextAlign.center,),
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



