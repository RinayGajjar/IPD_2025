import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drivers/global/global.dart';
import 'package:drivers/splashscreen/splash_screen.dart';
import 'package:drivers/tabPages/earning_tab.dart';
import 'package:drivers/tabPages/profile_tab.dart';
import 'package:drivers/tabPages/ratings_tab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tabPages/home_tab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController tabController; // Ensures tabController is non-null
  int selectedIndex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.animateTo(index); // Switch to the tapped tab
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      // Update selectedIndex when the tab is changed
      setState(() {
        selectedIndex = tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
          HomeTabPage(),
          EarningTab(),
          RatingsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Ratings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        unselectedItemColor: darkTheme ? Colors.black54 : Colors.white54,
        selectedItemColor: darkTheme ? Colors.black : Colors.white,
        backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 14),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }

  Future<Map<String, String>?> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt');

    if (token == null) {
      print("No token found");
      return null;
    }

    print("Fetching user info with token: $token");

    final response = await http.get(
      Uri.parse('http://10.0.2.2:5454/api/drivers/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 202) {
      final Map<String, dynamic> data = json.decode(response.body);
      await prefs.setInt('user_id', data['id']); // Store user ID
      print("Successfully fetched and stored user ID: ${data['id']}");

    } else {
      print("Failed to fetch user info: ${response.statusCode}");
      return null;
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

