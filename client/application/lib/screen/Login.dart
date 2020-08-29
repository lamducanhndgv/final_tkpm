import 'package:application/screen/HomePage.dart';
import 'package:application/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:application/utils/assets.dart';
import 'package:application/screen/SignUp.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
//class LoginPage extends StatelessWidget {
//}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Widget _buildPageContent(BuildContext context) {
    return Container(
      color: Colors.blue.shade100,
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          CircleAvatar(
            child: PNetworkImage(origami),
            maxRadius: 50,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(
            height: 20.0,
          ),
          _buildLoginForm(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _isLoading != true
                  ? FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => SignUp()));
                      },
                      child: Text("Sign Up",
                          style: TextStyle(color: Colors.blue, fontSize: 18.0)),
                    )
                  : FlatButton()
            ],
          )
        ],
      ),
    );
  }

  TextEditingController usernameControllerLogin = new TextEditingController();
  TextEditingController passwordControllerLogin = new TextEditingController();
  var _isLoading = false;

//  ProgressDialog pr;

  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: _isLoading
          ? Center(
              child: Padding(
                  padding: const EdgeInsets.only(top:100),
                  child: CircularProgressIndicator()))
          : Stack(
              children: <Widget>[
                ClipPath(
                  clipper: RoundedDiagonalPathClipper(),
                  child: Container(
                    height: 400,
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40.0)),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 90.0,
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              style: TextStyle(color: Colors.blue),
                              controller: usernameControllerLogin,
                              decoration: InputDecoration(
                                  hintText: "Username",
                                  hintStyle:
                                      TextStyle(color: Colors.blue.shade200),
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.email,
                                    color: Colors.blue,
                                  )),
                            )),
                        Container(
                          child: Divider(
                            color: Colors.blue.shade400,
                          ),
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20.0, bottom: 10.0),
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              style: TextStyle(color: Colors.blue),
                              obscureText: true,
                              controller: passwordControllerLogin,
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle:
                                      TextStyle(color: Colors.blue.shade200),
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.lock,
                                    color: Colors.blue,
                                  )),
                            )),
                        Container(
                          child: Divider(
                            color: Colors.blue.shade400,
                          ),
                          padding: EdgeInsets.only(
                              left: 20.0, right: 20.0, bottom: 10.0),
                        ),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      Container(padding: EdgeInsets.only(right: 20.0),
//                          child: Text("Forgot Password?",
//                            style: TextStyle(color: Colors.black45),
//                          )
//                      )
//                    ],
//                  ),
                        SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Colors.blue.shade600,
                      child: Icon(Icons.person),
                    ),
                  ],
                ),
                Container(
                  height: 420,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      onPressed: () {
                        attempLogin(usernameControllerLogin.text,
                            passwordControllerLogin.text);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Login",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  var _mIPLogin = SERVER_URL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(context),
    );
  }

  Future<String> attempLogin(String textUsername, String textPassword) async {
    print('login');
    setState(() {
      _isLoading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'username': textUsername, 'password': textPassword};
    var jsonResponse = null;

    var response = await http.post("$SERVER_URL/login", body: data);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (jsonResponse != null) {
        Fluttertoast.showToast(
            msg: "Login success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueAccent,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
    }
  }
}
