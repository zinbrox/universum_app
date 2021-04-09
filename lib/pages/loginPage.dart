import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:universum_app/helpers/sign_in.dart';
import 'package:universum_app/pages/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Future<void> googleCall() async {

    await Firebase.initializeApp();

    User user = FirebaseAuth.instance.currentUser;
    if(user!=null) {
      Navigator.of(context).push(
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
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Center(
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
        ),),
    );
  }
}
