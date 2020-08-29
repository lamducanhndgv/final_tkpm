import 'package:application/screen/HomePage.dart';
import 'package:application/screen/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}
final routes ={
  '/login':(BuildContext context)=>new LoginPage(),
  '/home': (BuildContext context)=> new HomePage(),
  '/':(BuildContext context)=>new LoginPage(),
};
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ACT Detection',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

