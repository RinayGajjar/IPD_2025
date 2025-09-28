

import 'package:flutter/material.dart';
import 'package:ipdapp/global/global.dart';
import 'package:ipdapp/screens/profile_screen.dart';
import 'package:ipdapp/splashscreen/splash_screen.dart';
import 'package:ipdapp/Models/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  Map<String, String>? userInfo;

  @override
  void initState() {
    super.initState();
    fetchUserInfo().then((data) {
      if (data != null) {
        setState(() {
          userInfo = data;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      width: 220,
      child: Drawer(
        child: Padding(
          padding: EdgeInsets.fromLTRB(50, 50, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 20,),

                  Text(
                    "userModelCurrentInfo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  SizedBox(height: 30,),

                  Text(
                    'Full Name: ${userInfo?['fullName'] ?? 'Loading...'}',
                    style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Mobile: ${userInfo?['mobile'] ?? 'Loading...'}',
                    style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.blue, fontSize: 16),
                  ),

                  SizedBox(height: 10,),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileScreen()));
                    },
                    child: Text(
                      "Edit profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.blue,
                      ),
                    ),
                  ),

                ],
              ),

              GestureDetector(
                onTap: () {
                  // firebaseAuth.signOut();
                  // Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                },
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

}


  

  Future<Map<String, String>?> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt');

    if (token == null) {
      print("No token found");
      return null;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5454/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'fullName': data['fullName'] ?? 'anonymous',
        'mobile': data['mobile'] ?? 'anonymous',
      };
    } else {
      print("Failed to fetch user info: ${response.statusCode}");
      return null;
    }
  }




