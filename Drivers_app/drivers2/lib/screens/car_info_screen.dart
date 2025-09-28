import 'package:drivers/splashscreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  final carModelTextEditingController = TextEditingController();
  final carNumberTextEditingController = TextEditingController();
  final carColorTextEditingController = TextEditingController();

  List<String> carTypes = ["Car", "CNG", "Bike"];
  String? selectedCarType;

  final _formKey = GlobalKey<FormState>();

  _submit() {
    if(_formKey.currentState!.validate()){
      Map driverCarInfoMap = {

        "car_model": carModelTextEditingController.text.trim(),
        "car_number": carNumberTextEditingController.text.trim(),
        "car_color": carColorTextEditingController.text.trim(),

      };




      Fluttertoast.showToast(msg: "Car details has been saved. Congratulations");
      Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));

    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city_night.jpg' : 'images/city_image.jpeg'),
                SizedBox(height: 20,),

                Text(
                  "Add Car Details",
                  style: TextStyle(
                    color: darkTheme ? Colors.grey.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(key:_formKey,child: Column(children: [
                        TextFormField(
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                            hintText: "Car Model",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Name can\'t be empty';
                            }
                            if (text.length < 2) {
                              return 'Enter a valid name';
                            }
                            if (text.length > 49) {
                              return 'Name can\'t be more than 50 characters';
                            }
                            return null;
                          },
                          onChanged: (text) {
                            setState(() {
                              carModelTextEditingController.text = text;
                            });
                          }, // Removed semicolon here
                        ),
                        SizedBox(height: 20),

                        TextFormField(
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                            hintText: "Car Number",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Name can\'t be empty';
                            }
                            if (text.length < 2) {
                              return 'Enter a valid name';
                            }
                            if (text.length > 49) {
                              return 'Name can\'t be more than 50 characters';
                            }
                            return null;
                          },
                          onChanged: (text) =>
                            setState(() {
                              carNumberTextEditingController.text = text;
                            }),
                           // Removed semicolon here
                        ),
                        SizedBox(height: 20),

                        TextFormField(
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          decoration: InputDecoration(
                            hintText: "Car Color",
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(width: 0, style: BorderStyle.none),
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (text) {
                            if (text == null || text.isEmpty) {
                              return 'Name can\'t be empty';
                            }
                            if (text.length < 2) {
                              return 'Enter a valid name';
                            }
                            if (text.length > 49) {
                              return 'Name can\'t be more than 50 characters';
                            }
                            return null;
                          },
                          onChanged: (text) =>
                            setState(() {
                              carColorTextEditingController.text = text;
                            }),// Removed semicolon here
                        ),
                        SizedBox(height: 20),

                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: "Please choose Car Type",
                            prefixIcon: Icon(Icons.car_crash, color: darkTheme? Colors.amber.shade400 : Colors.grey,),
                            fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              )
                            )
                          ),
                            items: carTypes.map((car) {
                              return DropdownMenuItem(
                                child: Text(
                                  car,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                value: car,
                              );
                            }).toList(),
                            onChanged: (newValue) {
                            setState(() {
                              selectedCarType = newValue.toString();
                            });
                            }
                        ),

                        SizedBox(height: 20,),

                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor : darkTheme ? Colors.amber.shade400 : Colors.blue,
                                foregroundColor : darkTheme ? Colors.black : Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32)
                                ),
                                minimumSize: Size(double.infinity, 50)
                            ),
                            onPressed: (){
                             _submit();
                            }, child: Text('Register',style: TextStyle(
                          fontSize: 20,
                        ),)),
                        SizedBox(height: 20,),
                        GestureDetector(
                          onTap: () {

                          },
                          child: Text('Forgot Password?',style: TextStyle(color: darkTheme ? Colors.amber.shade400:Colors.blue),),

                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Have an account?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),),
                            SizedBox(width: 5,),

                            GestureDetector(
                              onTap: (){
                              },
                              child: Text("Sign in",
                                style: TextStyle(fontSize: 15, color: darkTheme ? Colors.amber.shade400 : Colors.grey,),


                              ),
                            )
                          ],
                        )
                      ],

                      )),
                    ],
                  ),
                )

              ],
            )
          ],
        ),
      ),
    );
  }
}
