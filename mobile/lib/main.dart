import 'package:flutter/material.dart';

import 'dart:async';

import './services/auth.service.dart';
import './widgets/CustomWebView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'colors.dart';
import 'config.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eyo',
      home: Scaffold(
        body: LoginPage(),
      ),
    );
  }
}

enum AuthProvider { Twitter, Facebook }

class LoginPageState extends State<LoginPage> {
  OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: azure,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          signInButton(
            primaryColor: facebookBlue, 
            secondaryColor: facebookBlueDark, 
            txt: 'Connect With Facebook',
            icon: const Icon(
              FontAwesomeIcons.facebook,
              color: Colors.white,
            ),
            onTap: _loginWithFacebook
          ),
        ],
      ),
    );
  }

  List<Widget> showFailure() {
    return [
      Container(
        height: 200,
        width: 200,
        margin: EdgeInsets.only(top: 100.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          border: Border.all(
            color: persimmon,
            width: 10
          )
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Text(          
          'Please wait...',
          style: TextStyle(
            color: Color(0xffffffff),
            fontSize: 15,
            fontFamily: "Poppins"
          ),
        ),
      )
    ];
  }

  Widget verticalLine(){
    return  Container(
      height: 1.0,
      width: 60.0,
      color: zumthor,
      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
    );
  }

  Widget signInButton({
    @required Color primaryColor,
    @required Color secondaryColor,
    @required String txt,
    @required Icon icon,
    @required Function onTap
  }) {
    return InkWell(
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        width: MediaQuery.of(context).size.width * (0.8),
        height: 60,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 90,
              height: 60,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))
              ),
              child: icon,
            ),
            Container(
              margin: EdgeInsets.only(left: 40),
              child: Text(          
              txt,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: "Poppins",
              ),
            ),
            )
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _loginWithFacebook() async {
    Map<String, dynamic> result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => 
        CustomWebView(
          popOnMessage: true,
          selectedUrl: 'https://www.facebook.com/dialog/oauth?client_id=484737552229950&redirect_uri=$hostURL/user/facebook/code&scope=email,public_profile',
        ), 
        maintainState: true
      ),
    );

    if (result != null && result["authToken"] != null) {
      _sendTokenToServer(
        user: result,
        authProvider: AuthProvider.Facebook
      );
    } else {
      _showErrorOnUI(result != null ? 'Login error, this is our fault': 'You must be logged in to continue');
    }
  }

  _sendTokenToServer({
    String token,
    String secret, 
    AuthProvider authProvider,
    Map user
  }) {
    Map authBody = {"token": token, "authProvider": authProvider.toString(), "secret": secret};
    _showLoadingOverlay(context: context, child: CircularProgressIndicator());
    AuthService.authenticateToken(authBody: authBody, user: user)
        .then((e) {
          print(e);
          goBack(true);
        })
          .catchError((e) => goBack(false));
  }

  void _showLoadingOverlay({
    @required BuildContext context, 
    @required  Widget child
  }) {
    _overlayEntry = OverlayEntry(builder: (context) {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              top: 0,
              left: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Color(0x9f000000)
                  ),
                  child: Center(
                    child: child,
                  ),
                ),
              ),
            ],
          )
        );
      }
    );
    
    return Overlay.of(context).insert(
      _overlayEntry,
    );
  }

  _showErrorOnUI(String data) {
    _showLoadingOverlay(
      context: context, 
        child: Container(
          width: 250,
          height: 220,
          decoration: BoxDecoration(
            color: Color(0xfff2f5e9),
            borderRadius: BorderRadius.all(Radius.circular(5))
          ),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: const Icon(
                  Icons.cancel,
                  size: 60.0,
                  color: Color(0xFFD23600),
                ),
              ),
              Text(
                data,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mainTextColor,
                  fontSize: 18,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          )
        )
      ),
    );
  }

  goBack(bool success) {
    _overlayEntry.remove();
    Navigator.pop(context, success);
  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}
