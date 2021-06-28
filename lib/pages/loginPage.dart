import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universum_app/helpers/sign_in.dart';
import 'package:universum_app/pages/home.dart';
import 'package:universum_app/pages/homePage.dart';
import 'package:delayed_display/delayed_display.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _buttonVisible=false;

  Future<void> authCall() async {

    await Firebase.initializeApp();

    /*
      User user = FirebaseAuth.instance.currentUser;
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
        setState(() {
          _buttonVisible=true;
        });

     */

    setState(() {
      _buttonVisible=true;
    });



  }

  @override
  void initState() {
    super.initState();
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
              Text("Please Login", style: TextStyle(fontSize: 25),),
              Container(height: MediaQuery.of(context).size.height*0.025,),
              AnimatedOpacity(
                opacity: _buttonVisible ? 1 : 0,
                duration: Duration(milliseconds: 400),
                child: DelayedDisplay(
                  fadingDuration: Duration(seconds: 1),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: (){
                          signInWithGoogle().then((result) {
                            if (result != null) {
                              Navigator.of(context).push(
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
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Sign In With Google",
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
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(width: 1.0, color: Colors.black),
                        ),
                      ),
                      Container(height: 10,),
                      ElevatedButton(
                        onPressed: (){
                          signInWithFacebook().then((result) {
                            if (result != null) {
                              Navigator.of(context).push(
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
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Sign In With Facebook",
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
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(width: 1.0, color: Colors.black),
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


