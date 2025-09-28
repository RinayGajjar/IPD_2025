import 'dart:async';

import 'package:drivers/screens/login_screen.dart';
import 'package:flutter/material.dart';

import '../Assistants/assistant_methods.dart';
import '../global/global.dart';
import '../screens/main_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  @override
  void initState(){
    super.initState();
    //startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Trippo',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}
