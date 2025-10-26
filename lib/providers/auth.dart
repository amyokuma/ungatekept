import 'package:Loaf/user_respository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Loaf/models/user_model.dart';
import 'package:flutter/material.dart';

class Auth {
  final _auth = FirebaseAuth.instance;
  Future<void> signUp({required String email, required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = _auth.currentUser!;

    final newUser = UserModel(
      id: user.uid,
      name: user.email!.split("@")[0],
      email: user.email!,
    );

    await UserRepository.instance.createUser(newUser);
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
}
