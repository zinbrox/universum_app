import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<String> signInWithGoogle() async{


  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );
  final UserCredential authResult =   await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  if(user!=null){
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print("signInWithGoogle succeeded: $user");
    return "$user";
  }
  return null;
}

Future<void> signOutGoogle() async{
  await googleSignIn.signOut();
  print("User Signed Out");
}


Future<String> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult result = await FacebookAuth.instance.login();

  if (result.status == LoginStatus.success) {
    // you are logged
    final AccessToken accessToken = result.accessToken;
  }
  final AccessToken accessToken = await FacebookAuth.instance.accessToken;
  if (accessToken != null) {
    // Create a credential from the access token
    final facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);
    // Once signed in, return the UserCredential
    final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    final User user = authResult.user;
    if(user!=null){
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      print("signInWithFacebook succeeded: $user");
      return "$user";
    }
    return null;
  }
  else
    return null;

}



