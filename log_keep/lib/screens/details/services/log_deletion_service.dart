import 'dart:async';

import 'package:flutter/material.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/common/dialogs/confirm_dialog.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep_shared/log_keep_shared.dart';
import 'package:uiblock/uiblock.dart';

class LogDeletionService {
  static Future<bool> requestDeletion(
      BuildContext context, String project, LogInfoEntity logInfo) {
    var result = new Completer<bool>();

    var params = ConfirmDialogParams(
        "Log Deletion",
        "Are you sure you want to delete this log?",
        "Cancel",
        "Delete",
        () => {
              performDeletion(context, project, logInfo)
                  .whenComplete(() => result.complete(true))
            },
        () => {result.complete(false)});

    showConfirmDialog(context, params);

    return result.future;
  }

  static Future performDeletion(
      BuildContext context, String project, LogInfoEntity logInfo) {
    UIBlock.block(context,
        loadingTextWidget: Text('Deleting..,'));

    var future = getIt<LogsRepository>().removeLog(project, logInfo.id);

    future.whenComplete(() => UIBlock.unblock(context));

    return future;
  }
}
