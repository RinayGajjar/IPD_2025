import 'package:drivers/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../splashscreen/splash_screen.dart';
import 'package:drivers/Models/user_model.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    userModelCurrentInfo!.name!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
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

                  SizedBox(height: 30,),

                  Text("Your Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),

                  Text("Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),

                  Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),

                  Text("Promos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),

                  Text("Help", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                  SizedBox(height: 15,),

                  Text("Free Trips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),

                ],
              ),

              GestureDetector(
                onTap: () {
                  firebaseAuth.signOut();
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
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
