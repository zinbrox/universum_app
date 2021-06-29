import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universum_app/helpers/sign_in.dart';
import 'package:universum_app/pages/explorePage.dart';
import 'package:universum_app/pages/home.dart';
import 'package:delayed_display/delayed_display.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _buttonVisible=false;

  Future<void> authCall() async {

    await Firebase.initializeApp();

      User user = FirebaseAuth.instance.currentUser;
      Future.delayed(const Duration(seconds: 1), (){
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return Home();
              },
            ),
          );
        }
        else
          Future.delayed(const Duration(seconds: 2), (){
            setState(() {
              _buttonVisible=true;
            });
          });
      });

    /*
    setState(() {
      _buttonVisible=true;
    });
     */


  }

  Future<void> loadImages() async {
    await Future.wait(
      images.map((image) => cacheImage(context, image)).toList(),
    );
  }
  Future cacheImage(BuildContext context, String image) => precacheImage(AssetImage(image), context);

  @override
  void initState() {
    super.initState();
    //loadImages();
    authCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/LoginScreenBackground.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: AssetImage("assets/OrbitFeedLogo.png"), height: 150,),
                    Text("orbitfeed", style: GoogleFonts.getFont("Comfortaa", fontSize: 30,)),
                    //Text("OrbitFeed", style: TextStyle(fontSize: 25),),
                  ],
                ),
              ),
              //Container(height: MediaQuery.of(context).size.height*0.025,),
              AnimatedOpacity(
                opacity: _buttonVisible ? 1 : 0,
                duration: Duration(milliseconds: 400),
                child: DelayedDisplay(
                  fadingDuration: Duration(seconds: 1),
                  child: Column(
                    children: [
                      Text("Please Login", style: TextStyle(fontSize: 25),),
                      Container(height: 10,),
                      ElevatedButton(
                        onPressed: (){
                          signInWithGoogle().then((result) {
                            if (result != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Home();
                                  },
                                ),
                              );
                            }
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.65,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset("assets/GoogleLogo.png", height: 40.0,),
                              Flexible(
                                child: Text(
                                  "Sign In With Google",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont("Open Sans",
                                      color: Colors.black,
                                      fontSize: 20.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          padding: const EdgeInsets.all(8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      Container(height: 10,),
                      ElevatedButton(
                        onPressed: (){
                          signInWithFacebook().then((result) {
                            if (result != null) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return Home();
                                  },
                                ),
                              );
                            }
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width*0.65,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset("assets/FacebookLogo.png", height: 40.0,),
                              Flexible(
                                child: Text(
                                  "Sign In With Facebook",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont("Open Sans",
                                      color: Colors.white,
                                      fontSize: 20.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF3c5a99),
                          padding: const EdgeInsets.all(8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50,),
              Text("zinbrox", style: TextStyle(fontSize: 20, decoration: TextDecoration.overline),),
              SizedBox(height: 10,),
            ],
          ),),
      ),
    );
  }
}


