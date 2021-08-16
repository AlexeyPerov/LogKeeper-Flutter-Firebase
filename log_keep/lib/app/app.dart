import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:log_keep/bloc/loggable_bloc_observer.dart';
import 'package:log_keep/repositories/auth_repository.dart';
import 'package:log_keep/repositories/logs_repository.dart';
import 'package:log_keep/repositories/mock/mock_auth_repository.dart';
import 'package:log_keep/repositories/mock/mock_logs_repository.dart';
import 'package:logger/logger.dart';

GetIt getIt = GetIt.instance;
FirebaseApp firebaseApp;

Logger logger;

class App {
  static Future initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    initializeLogging();

    if (!kReleaseMode) {
      Bloc.observer = LoggableBlocObserver();
    }

    getIt.registerSingleton<AuthRepository>(
        MockAuthRepository(),
        signalsReady: true);

    getIt.registerSingleton<LogsRepository>(
        MockLogsRepository(),
        signalsReady: true);

    // TODO uncomment this when your Firebase account is ready
    /*
    firebaseApp = await Firebase.initializeApp();

    getIt.registerSingleton<AuthRepository>(
        FirebaseAuthRepository(),
        signalsReady: true);

    getIt.registerSingleton<LogsRepository>(
        FirestoreLogsRepository(FirebaseFirestore.instance),
        signalsReady: true);
    */

    getIt<AuthRepository>().initialize();
    getIt<LogsRepository>().initialize();
  }

  static void initializeLogging() {
    logger = Logger(
      filter: CommonLogFilter(),
      printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: false
      ),
    );
  }
}

class CommonLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return !kReleaseMode;
  }
}