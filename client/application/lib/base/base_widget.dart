import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageContainer extends StatelessWidget {
  final String title;
  final Widget child;

  final List<SingleChildCloneableWidget> bloc;
  final List<SingleChildCloneableWidget> di;

  PageContainer({this.title, this.bloc, this.di, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiProvider(
        providers: [
          ...di,
          ...bloc,
        ],
        child: child,
      ),
    );
  }
}