import 'package:flutter/material.dart';
import 'package:log_keep/common/utilities/navigator_utilities.dart';
import 'package:log_keep/screens/home/home_screen.dart';

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFCC02),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 142),
              SizedBox(height: 30),
              TextButton(
                  child: Text(
                "Back To Home".toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold),
              ),
                onPressed: () {
                  NavigatorUtilities.pushAndRemoveUntil(
                      context, (c) => HomeScreen());
                }),
            ],
          ),
        ));
  }
}
