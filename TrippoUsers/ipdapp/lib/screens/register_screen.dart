import 'package:email_validator/email_validator.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ipdapp/global/global.dart';
import 'package:ipdapp/screens/main_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

      if (response.statusCode == 202) {
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
        Uri.parse('http://10.0.2.2:5454/api/auth/user/signup'),
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
                Image.asset(darkTheme ? 'images/city_night.jpg':'images/city_image.jpeg'),

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
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  controller: nameTextEditingController,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(width: 0, style: BorderStyle.none),
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
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: emailTextEditingController,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Email can\'t be empty';
                    }
                    if (!EmailValidator.validate(text)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Field
                IntlPhoneField(
                  showCountryFlag: true,
                  dropdownIcon: Icon(
                    Icons.arrow_drop_down,
                    color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                  ),
                  decoration: InputDecoration(
                    hintText: "Phone",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(width: 0, style: BorderStyle.none),
                    ),
                  ),
                  initialCountryCode: 'IN',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.completeNumber.isEmpty) {
                      return 'Phone number can\'t be empty';
                    }
                    if (value.completeNumber.length < 10 || value.completeNumber.length > 15) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                  onChanged: (phone) {
                    // Instead of updating controller, directly update the value
                    phoneTextEditingController.text = phone.completeNumber;
                    // Set the cursor to the end of the input to avoid it moving to the beginning
                    phoneTextEditingController.selection = TextSelection.fromPosition(TextPosition(offset: phoneTextEditingController.text.length));
                  },
                ),
                    // TextFormField(
                    //   inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    //   decoration: InputDecoration(
                    //     hintText: "Address",
                    //     hintStyle: TextStyle(color: Colors.grey),
                    //     filled: true,
                    //     fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(40),
                    //       borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    //     ),
                    //     prefixIcon: Icon(
                    //       Icons.person,
                    //       color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                    //     ),
                    //   ),
                    //   autovalidateMode: AutovalidateMode.onUserInteraction,
                    //   validator: (text) {
                    //     if (text == null || text.isEmpty) {
                    //       return 'Address can\'t be empty';
                    //     }
                    //     if (text.length < 2) {
                    //       return 'Enter a valid Address';
                    //     }
                    //     if (text.length > 99) {
                    //       return 'Address can\'t be more than 100 characters';
                    //     }
                    //     return null;
                    //   },
                    //   onChanged: (text) {
                    //     setState(() {
                    //       addressTextEditingController.text = text;
                    //     });
                    //   },
                    // ),
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
                    // SizedBox(height: 20,),
                    //
                    // TextFormField(
                    //   obscureText: !_passwordVisible,
                    //   inputFormatters: [LengthLimitingTextInputFormatter(50)],
                    //   decoration: InputDecoration(
                    //     hintText: "Confirm Password",
                    //     hintStyle: TextStyle(color: Colors.grey),
                    //     filled: true,
                    //     fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(40),
                    //       borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    //     ),
                    //     prefixIcon: Icon(
                    //       Icons.person,
                    //       color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                    //     ),
                    //     suffixIcon: IconButton(
                    //       icon: Icon(
                    //         _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    //         color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                    //       ),
                    //       onPressed: () {
                    //         setState(() {
                    //           _passwordVisible = !_passwordVisible;
                    //         });
                    //       },
                    //     ),
                    //   ),
                    //   autovalidateMode: AutovalidateMode.onUserInteraction,
                    //   validator: (text) {
                    //     if (text == null || text.isEmpty) {
                    //       return 'Confirm Password can\'t be empty';
                    //     }
                    //     if(text!=passwordTextEditingController.text){
                    //       return 'Passwords do not match';
                    //     }
                    //     if (text.length < 2) {
                    //       return 'Enter a valid Confirm Password';
                    //     }
                    //     if (text.length > 49) {
                    //       return 'Password can\'t be more than 100 characters';
                    //     }
                    //     return null;
                    //   },
                    //   onChanged: (text) {
                    //     setState(() {
                    //       confirmTextEditingController.text = text;
                    //     });
                    //   },
                    // ),
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
