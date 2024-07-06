import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninApi{
  static final _goodleSignIn = GoogleSignIn();
  static Future<GoogleSignInAccount?> login() => _goodleSignIn.signIn();

}