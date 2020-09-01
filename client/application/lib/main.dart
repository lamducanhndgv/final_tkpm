import 'package:application/module/signup/signup_page.dart';
import 'package:application/module/home/home_page.dart';
import 'package:flutter/material.dart';
import 'module/signin/signin_page.dart';


void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
       routes:<String,WidgetBuilder>{
         '/': (context) => SignIn(),
         '/login': (context)=>SignIn(),
         '/register': (context)=>RegisterPage(),
         '/home' : (context)=>HomePage(),
       },
    );
  }
}

