import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:log_keep/app/app.dart';
import 'package:log_keep/repositories/auth_repository.dart';
import 'package:log_keep/repositories/settings_repository.dart';

import 'mock_utilities.dart';

class MockAuthRepository extends AuthRepository {
  bool _loggedIn = true;

  @override
  Future initialize() {
    getIt<SettingsRepository>().putString("last_login_name", "JustPressLogin");
    return Future.value();
  }

  bool isRequired() {
    return true;
  }

  bool isLoggedIn() {
    return _loggedIn;
  }

  String loggedInEmail() {
    return _loggedIn ? "test@mail.com" : "";
  }

  Future<void> logout() {
    _loggedIn = false;
    return Future.value();
  }

  @override
  Future<Either<AppUser, Exception>> authenticate(
      String login, String password) async {
    await fakeDelay();

    _loggedIn = true;

    return Left<AppUser, Exception>(
        AppUser(uid: "0", email: "test@mail.com", displayName: "Test"));
  }
}
