import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ipdapp/screens/forgot_password_screen.dart';
import 'package:ipdapp/screens/register_screen.dart';
import 'package:ipdapp/splashscreen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../global/global.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    Future<void> loginUser() async {
      final url = Uri.parse('http://10.0.2.2:5454/api/auth/signin'); // Update for your backend URL

      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'email': emailTextEditingController.text.trim(),
        'password': passwordTextEditingController.text.trim(),
      });

      try {
        final response = await http.post(url, headers: headers, body: body);
        print("------Login Attempt-----");

        if (response.statusCode == 200) {
          print("------Login Successful-----");
          final responseData = jsonDecode(response.body);

          // Save JWT Token using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt', responseData['jwt']);

          Fluttertoast.showToast(msg: responseData['message']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => MainScreen()), // Replace with your main screen
          );
        } else {
          print("------Login Failed-----");
          final responseData = jsonDecode(response.body);
          Fluttertoast.showToast(msg: responseData['message']);
        }
      } catch (error) {
        print("------Error Occurred During Login-----");
        Fluttertoast.showToast(msg: 'An error occurred: $error');
      }
    }


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
                Image.asset(darkTheme ? 'images/city_night.jpg':'images/city_image.jpeg'),

                SizedBox(height: 20,),

                Text(
                  'Login',
                  style : TextStyle(
                    color:darkTheme ? Colors.amber.shade400 : Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(key:_formKey,child: Column(children: [

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
                          loginUser();
                        }, child: Text('Login',style: TextStyle(
                      fontSize: 20,
                    ),)),
                    SizedBox(height: 20,),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                      },
                      child: Text('Forgot Password?',style: TextStyle(color: darkTheme ? Colors.amber.shade400:Colors.blue)),

                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Doesn,t have an account?",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),),
                        SizedBox(width: 5,),

                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
                          },
                          child: Text("Register",
                            style: TextStyle(fontSize: 15, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),


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
