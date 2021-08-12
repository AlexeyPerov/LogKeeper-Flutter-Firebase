import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: kIsWeb
            ? AppBar(
                leading: Container(),
              )
            : Container(),
        body: Align(
            alignment: Alignment.center,
            child: LinearProgressIndicator()));
  }
}
