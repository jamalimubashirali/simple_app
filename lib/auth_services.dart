import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService{
  final _auth = FirebaseAuth.instance;


  Future<User?> signUp(String password , String email) async{
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch(e){
      print(e);
      return null;
    }
  }


  Future<User?> signIn(String password , String email) async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch(e){
      print(e);
      return null;
    }
  }

  signOut() async{
    await _auth.signOut();
  }
}