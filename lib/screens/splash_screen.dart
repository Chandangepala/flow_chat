import 'dart:async';

import 'package:flow_chat/data/remote/firebase_repository.dart';
import 'package:flow_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../utils/SharedPref.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final String IS_LOGGED_IN = "IS_LOGGED_IN";
  Timer? timer;
  @override
  void initState() {
    super.initState();
    decidePageNavigation();

  }

  decidePageNavigation() {

    timer = Timer(Duration(seconds: 3), () async{
      try{
        SharedPref sharedPref =  SharedPref();
        String userId = await sharedPref.getSharedPref(FirebaseRepository.PREF_USER_KEY);
        print("userId: $userId");
        if(userId.isNotEmpty) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(userId: userId)));
        }else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }catch(e){
        print("Error: splash screen: sharedPref: $e");
        Navigator.pushReplacementNamed(context, '/login');
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black45,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Icon(Icons.apple, size: 100, color: Colors.white),
      ),
    );
  }
}
