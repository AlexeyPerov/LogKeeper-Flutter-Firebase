import 'dart:async';

import 'package:flutter/material.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/common/dialogs/confirm_dialog.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:uiblock/uiblock.dart';

class ProjectArchivingService {
  static Future<bool> requestArchiving(BuildContext context, String project) {
    var result = new Completer<bool>();

    var params = ConfirmDialogParams(
        "Project Archiving",
        "Are you sure you want to archive this project? "
            "If you later add a new log to it,"
            " the whole project will be restored.",
        "Cancel",
        "Archive",
        () => {
              performArchiving(context, project)
                  .whenComplete(() => result.complete(true))
            },
        () => {result.complete(false)});

    showConfirmDialog(context, params);

    return result.future;
  }

  static Future performArchiving(BuildContext context, String project) {
    UIBlock.block(context, loadingTextWidget: Text('Archiving..,'));

    var future = getIt<LogsRepository>().archiveProject(project);
    future.whenComplete(() => UIBlock.unblock(context));
    return future;
  }
}
