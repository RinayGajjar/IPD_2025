import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String fullName = "Fetching Name...";
  String email = "Fetching Email...";
  String mobile = "Fetching Mobile...";
  String id = "Fetching ID...";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      if (jwt == null) {
        setState(() {
          fullName = "Not Authenticated";
          email = "Not Authenticated";
          mobile = "Not Authenticated";
          id = "Not Authenticated";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5454/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);

        int? userId = data['id'];
        if (userId != null) {
          await prefs.setInt('user_id', userId); // Store driver_id
          print("User ID stored successfully: $userId");
        }

        setState(() {
          fullName = data['fullName'] ?? "N/A";
          email = data['email'] ?? "N/A";
          mobile = data['mobile'] ?? "N/A";
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        setState(() {
          fullName = "Error fetching data";
          email = "Error fetching data";
          mobile = "Error fetching data";
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        fullName = "Error occurred";
        email = "Error occurred";
        mobile = "Error occurred";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                SizedBox(height: 20),
                Text(
                  fullName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  mobile,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
            GestureDetector(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear JWT
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
