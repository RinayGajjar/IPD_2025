import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, String>? userInfo;

  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchDriverDetails().then((data) {
      if (data != null) {
        setState(() {
          userInfo = data;
        });
      }
    });
  }

  Future<Map<String, String>?> fetchDriverDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt');

    if (token == null) {
      print("No token found");
      isLoading = false;
      return null;

    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5454/api/drivers/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      isLoading = false;
      final Map<String, dynamic> data = json.decode(response.body);
      return {
        'fullName': data['full_name'] ?? 'anonymous',
        'mobile': data['mobile'] ?? 'anonymous',
      };
    } else {
      isLoading = false;
      print("Failed to fetch user info: ${response.statusCode}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
    }

    // if (driverDetails == null) {
    //   return const Center(child: Text('No driver details available.'));
    // }

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
