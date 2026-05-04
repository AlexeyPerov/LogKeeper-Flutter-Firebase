import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = '/splash';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: kIsWeb
            ? AppBar(
                leading: const SizedBox.shrink(),
              )
            : null,
        body: const Align(
            alignment: Alignment.center,
            child: LinearProgressIndicator()));
  }
}
