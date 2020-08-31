import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:application/shared/network_image.dart';
import 'package:application/shared/assets.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController passwordConfirmController = new TextEditingController();
  var _mIPSignup = SERVER_URL;
  var _isLoading = false;

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _isLoading != true
                  ? FloatingActionButton(
                      mini: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.arrow_back),
                    )
                  : Center()
            ],
          )
        ],
      ),
    );
  }

  Container _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: _isLoading
          ? Center(
              child: Padding(
                  padding: const EdgeInsets.only(top: 100),
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
                              controller: usernameController,
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
                              controller: passwordController,
                              obscureText: true,
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
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              style: TextStyle(color: Colors.blue),
                              obscureText: true,
                              controller: passwordConfirmController,
                              decoration: InputDecoration(
                                  hintText: "Confirm password",
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
                        if (passwordController.text
                                .compareTo(passwordConfirmController.text) ==
                            0)
                          attempSignUp(
                              usernameController.text, passwordController.text);
                        else {
                          Fluttertoast.showToast(
                              msg: "Password do not match",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.blueAccent,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      child: Text("Sign Up",
                          style: TextStyle(color: Colors.white70)),
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(context),
    );
  }

  Future<int> attempSignUp(String username, String password) async {
    setState(() {
      _isLoading = true;
    });

    Map data = {'username': username, 'password': username};
    try {
      var response = await http.post("$SERVER_URL/signup", body: data);
      if (response.statusCode == 200) {
        showToast('Sign up success');
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
            (Route<dynamic> route) => false);
      } else {
        showToast('Sign up failed');
        setState(() {
          _isLoading = false;
        });
        print(response.body);
      }
    } on SocketException catch (e) {
      print(e.toString());
    }
  }

  showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
