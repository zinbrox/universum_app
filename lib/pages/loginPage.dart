import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:universum_app/helpers/sign_in.dart';
import 'package:universum_app/pages/home.dart';
import 'package:universum_app/pages/homePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Future<void> googleCall() async {

    await Firebase.initializeApp();

    User user = FirebaseAuth.instance.currentUser;
    if(user!=null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return Home();
          },
        ),
      );
    }


  }

  @override
  void initState() {
    super.initState();
    googleCall();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(image: AssetImage("assets/OrbitFeedLogo.png"), height: 300,),
                  Text("OrbitFeed", style: TextStyle(fontSize: 30),),
                ],
              ),
            ),
            Expanded(
              child: ElevatedButton(
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
                child: Text("Login"),
              ),
            ),
            Text("zinbrox", style: TextStyle(fontSize: 20, decoration: TextDecoration.overline),),
            SizedBox(height: 10,),
          ],
        ),),
    );
  }
}


