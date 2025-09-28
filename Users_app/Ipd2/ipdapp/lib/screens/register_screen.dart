import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ipdapp/global/global.dart';
import 'package:ipdapp/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  final _formkey = GlobalKey<FormState>();

  // get http => null;

  Future<void> registerUser() async {
    final url = Uri.parse('http://10.0.2.2:5454/api/auth/user/signup'); // Update for your backend URL

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': emailTextEditingController.text.trim(),
      'password': passwordTextEditingController.text.trim(),
      'fullName': nameTextEditingController.text.trim(),
      'mobile': phoneTextEditingController.text.trim(),
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("------1-----");

      if (response.statusCode == 202 || response.statusCode == 200) {
        print("-----2----");
        final responseData = jsonDecode(response.body);

        // Save JWT Token using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', responseData['jwt']);

        Fluttertoast.showToast(msg: responseData['message']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => MainScreen()),
        );
      } else {
        print("----3-----");
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(msg: responseData['message']);
      }
    } catch (error) {
      print("----4-----");
      Fluttertoast.showToast(msg: 'An error occurred: $error');
    }
  }



  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jwt = prefs.getString('jwt');

    if (jwt != null) {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      };

      final response = await http.get(
        Uri.parse('http://localhost:5454/api/your_authenticated_endpoint'),
        headers: headers,
      );

      // Handle the response
    } else {
      Fluttertoast.showToast(msg: 'Not authenticated');
    }
  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(0),
          children : [
            Column(
              children: [
                Image.asset(darkTheme ? 'images/city-image.png':'images/city-image.png'),

                SizedBox(height: 20,),

                Text(
                  'Register',
                  style : TextStyle(
                    color:darkTheme ? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(key:_formkey,child: Column(children: [
                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "Name",
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
                          nameTextEditingController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "email",
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
                          return 'email can\'t be empty';
                        }
                        if (EmailValidator.validate(text) == true){
                          return null;
                        }
                        if (text.length < 2) {
                          return 'Enter a valid email';
                        }
                        if (text.length > 99) {
                          return 'email can\'t be more than 100 characters';
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {
                          emailTextEditingController.text = text;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    IntlPhoneField(
                      showCountryFlag: false,
                      dropdownIcon: Icon(
                          Icons.arrow_drop_down,
                        color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                      ),
                      decoration: InputDecoration(
                        hintText: "Phone",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(width: 0, style: BorderStyle.none),
                        ),
                      ),
                      initialCountryCode: 'IND',
                      onChanged: (text) => setState(() {
                        phoneTextEditingController.text = text.completeNumber;
                      }),
                    ),

                    SizedBox(height: 20,),

                    TextFormField(
                      obscureText: !_passwordVisible,
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "Password",
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Password can\'t be empty';
                        }
                        if (text.length < 2) {
                          return 'Enter a valid Password';
                        }
                        if (text.length > 49) {
                          return 'Password can\'t be more than 100 characters';
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {
                          passwordTextEditingController.text = text;
                        });
                      },
                    ),

                    SizedBox(height: 10,),
                    
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
                          registerUser();
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
