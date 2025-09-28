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

  Future<void> signInUser(BuildContext context, TextEditingController emailTextEditingController,
      TextEditingController passwordTextEditingController) async {

    final url = Uri.parse('http://10.0.2.2:5454/api/auth/signin'); // Update with your backend URL
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': emailTextEditingController.text.trim(),
      'password': passwordTextEditingController.text.trim(),
    });

    print("------1----- Sign-In Request Sent");

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("------2----- Response Received: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("------3----- Success Case");

        final responseData = jsonDecode(response.body);

        // Save JWT Token using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', responseData['jwt']);

        Fluttertoast.showToast(msg: responseData['message']);

        // Navigate to MainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => MainScreen()),
        );
      } else {
        print("------4----- Error Case: ${response.statusCode}");
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(msg: responseData['message']);
      }
    } catch (error) {
      print("------5----- Exception: $error");
      Fluttertoast.showToast(msg: 'An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // void submit() async{
    //   if(_formKey.currentState!.validate()){
    //     await firebaseAuth.signInWithEmailAndPassword(
    //         email: emailTextEditingController.text.trim(),
    //         password: passwordTextEditingController.text.trim()
    //     ).then((auth) async {
    //
    //       DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
    //       userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async{
    //         final snap = value.snapshot;
    //         if(snap.value != null){
    //           currentUser = auth.user;
    //           await Fluttertoast.showToast(msg: "Successfully Logged in");
    //           Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
    //         }
    //         else {
    //           await Fluttertoast.showToast(msg: "No record exist with this email");
    //           firebaseAuth.signOut();
    //           Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
    //         }
    //       });
    //     }).catchError((errorMessage){
    //       Fluttertoast.showToast(msg: "Error occured \n $errorMessage");
    //     });
    //   }
    //   else{
    //     Fluttertoast.showToast(msg: "Not all field are valid");
    //   }
    // }

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
                          signInUser(context, emailTextEditingController, passwordTextEditingController);
                        }, child: Text('Login',style: TextStyle(
                      fontSize: 20,
                    ),)),
                    SizedBox(height: 20,),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                      },
                      child: Text('Forgot Password?',style: TextStyle(color: darkTheme ? Colors.amber.shade400:Colors.blue),),

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
