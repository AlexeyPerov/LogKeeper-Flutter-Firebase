import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class AuthRepository {
  Future<void> initialize();
  bool isRequired();
  bool isLoggedIn();
  String loggedInEmail();
  Future<void> logout();
  Future<Either<AppUser, Exception>> authenticate(String login, String password);
}

class FirebaseAuthRepository extends AuthRepository {
  @override
  Future<void> initialize() {
    return Future.value();
  }

  @override
  bool isRequired() {
    return kReleaseMode;
  }

  @override
  bool isLoggedIn() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.currentUser != null;
  }

  @override
  String loggedInEmail() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.currentUser?.email ?? '';
  }

  @override
  Future<void> logout() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.signOut();
  }

  @override
  Future<Either<AppUser, Exception>> authenticate(
      String login, String password) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    try {
      final userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: login,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return Right(Exception('No user returned'));
      }
      return Left<AppUser, Exception>(_userFromFirebase(user));
    } catch (e) {
      return Right<AppUser, Exception>(
          e is Exception ? e : Exception(e.toString()));
    }
  }

  AppUser _userFromFirebase(User user) {
    return AppUser(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '');
  }
}

@immutable
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  final String uid;
  final String email;
  final String displayName;
}
