import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/theme_constants.dart';

import 'components/add_log_form.dart';

class AddLogScreen extends StatelessWidget {
  final AddLogFormParameters logForm;

  AddLogScreen({this.logForm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child(context),
    );
  }

  Widget child(BuildContext context) {
    if (kIsWeb) {
      var width = MediaQuery.of(context).size.width;
      return Align(
        alignment: Alignment.center,
        child: Container(
            width: min(kMinWebContainerWidth, width),
            child: AddLogForm(form: logForm)),
      );
    } else {
      return SafeArea(child: AddLogForm(form: logForm));
    }
  }
}