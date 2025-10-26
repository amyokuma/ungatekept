import 'package:Loaf/models/UserModel.dart';
import 'package:Loaf/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {
  final userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        id: _auth.currentUser!.uid,
        name:
            _auth.currentUser!.displayName ??
            _auth.currentUser!.email!.split('@')[0],
        email: _auth.currentUser!.email!,
      );

      await userService.createUser(newUser);
    } catch (e) {
      print('Error during sign up: $e');
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
  }

  Future<String?> getCurrentUser() async {
    var currentUser = _auth.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    return null;
  }
}
