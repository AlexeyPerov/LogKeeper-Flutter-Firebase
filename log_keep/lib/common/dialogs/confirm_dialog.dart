import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmDialogParams {
  final String title;
  final String contents;

  final String cancelButtonText;
  final String approveButtonText;
  final Function approveAction;

  ConfirmDialogParams(this.title, this.contents, this.cancelButtonText,
      this.approveButtonText, this.approveAction);
}

Future<void> showConfirmDialog(BuildContext context, ConfirmDialogParams arguments) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(arguments.title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(arguments.contents)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(arguments.cancelButtonText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(arguments.approveButtonText),
            onPressed: () {
              arguments.approveAction();
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
