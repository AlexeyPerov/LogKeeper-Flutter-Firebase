import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class AuthRepository {
  Future initialize();
  bool isRequired();
  bool isLoggedIn();
  String loggedInEmail();
  Future<void> logout();
  Future<Either<AppUser, Exception>> authenticate(String login, String password);
}

class FirebaseAuthRepository extends AuthRepository {
  @override
  Future initialize() {
    return Future.value();
  }

  bool isRequired() {
    return kReleaseMode;
  }

  bool isLoggedIn() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.currentUser != null;
  }

  String loggedInEmail() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.currentUser != null
        ? firebaseAuth.currentUser.email
        : "";
  }

  Future<void> logout() {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return firebaseAuth.signOut();
  }

  @override
  Future<Either<AppUser, Exception>> authenticate(
      String login, String password) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    UserCredential userCredential;

    try {
      userCredential =
      await firebaseAuth.signInWithEmailAndPassword(
        email: login,
        password: password,
      );

      return Left<AppUser, Exception>(_userFromFirebase(userCredential.user));
    } catch(e) {
      return Right<AppUser, Exception>(e);
    }
  }

  AppUser _userFromFirebase(User user) {
    if (user == null) {
      return null;
    }
    return AppUser(
        uid: user.uid, email: user.email, displayName: user.displayName);
  }
}

@immutable
class AppUser {
  const AppUser({
    @required this.uid,
    this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String displayName;
}
