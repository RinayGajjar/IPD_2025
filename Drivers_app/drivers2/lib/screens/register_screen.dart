import 'dart:async';
import 'dart:convert';

import 'package:drivers/screens/car_info_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Assistants/assistant_methods.dart';
import '../global/global.dart';
import 'main_screen.dart';
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
  final licenseNumberController = TextEditingController();
  final licenseStateController = TextEditingController();
  final licenseExpirationDateController = TextEditingController();
  final vehicleMakeController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final vehicleYearController = TextEditingController();
  final vehicleColorController = TextEditingController();
  final licensePlateController = TextEditingController();
  final vehicleCapacityController = TextEditingController();
  LocationPermission? _locationPermission;
  bool _passwordVisible = false;

  final _formkey = GlobalKey<FormState>();

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geolocator = Geolocator();

  String? fetchedDriverArea;

  Future<void> fetchDriverAddress() async {
    try {
      // Request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are denied.');
      }

      // Fetch current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Fetch human-readable address using Geocoder2
      GeoData data = await Geocoder2.getDataFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        googleMapApiKey: 'AIzaSyDawb9UusQEnQQe1TVYHeKK9q-toCNjr1s', // Replace with your API key
      );

      // Save the fetched address in a variable
      fetchedDriverArea = data.address;

      print("Fetched Address: $fetchedDriverArea");
      Fluttertoast.showToast(msg: 'Address fetched successfully');
    } catch (error) {
      print("Error fetching address: $error");
      Fluttertoast.showToast(msg: 'Error fetching address: $error');
    }
  }



  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }




  Future<void> registerDriver() async {
    final url = Uri.parse('http://10.0.2.2:5454/api/auth/driver/signup'); // Update with your backend URL

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': emailTextEditingController.text.trim(),
      'password': passwordTextEditingController.text.trim(),
      'fullName': nameTextEditingController.text.trim(),
      'mobile': phoneTextEditingController.text.trim(),
      'driverArea': fetchedDriverArea, // Address fetched from location
      'license': {
        'licenseNumber': licenseNumberController.text.trim(),
        'licenseState': licenseStateController.text.trim(),
        'licenseExpirationDate': licenseExpirationDateController.text.trim(),
      },
      'vehicle': {
        'make': vehicleMakeController.text.trim(),
        'model': vehicleModelController.text.trim(),
        'year': int.parse(vehicleYearController.text.trim()),
        'color': vehicleColorController.text.trim(),
        'licensePlate': licensePlateController.text.trim(),
        'capacity': int.parse(vehicleCapacityController.text.trim()),
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 202) {
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
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(msg: responseData['message'] ?? 'Error occurred');
      }
    } catch (error) {
      print("Error: $error");
      Fluttertoast.showToast(msg: 'An error occurred: $error');
    }
  }
  @override
  void dispose() {
    licenseExpirationDateController.dispose(); // Dispose controller to free up resources
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Form(key:_formkey,child: Column(children: [
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

                    SizedBox(height: 20,),
                    Text("License Information",style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkTheme ? Colors.amber.shade400 : Colors.grey
                    ),),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "License Number",
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

                      onChanged: (text) {
                        setState(() {
                          licenseNumberController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "License State",
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

                      onChanged: (text) {
                        setState(() {
                          licenseStateController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 10,),

                    TextFormField(
                      controller: licenseExpirationDateController, // Link the controller
                      readOnly: true, // Prevents manual editing
                      decoration: InputDecoration(
                        hintText: "License Expiry Date (DD/MM/YYYY)",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(width: 0, style: BorderStyle.none),
                        ),
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                        ),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Date can\'t be empty';
                        }

                        final dateRegex = RegExp(
                            r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/([0-9]{4})$');
                        if (!dateRegex.hasMatch(text)) {
                          return 'Enter a valid date (DD/MM/YYYY)';
                        }

                        return null; // Valid input
                      },
                      onTap: () async {
                        // Show date picker dialog
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900), // Earliest date the user can select
                          lastDate: DateTime(2100), // Latest date the user can select
                        );

                        if (pickedDate != null) {
                          // Format the picked date as DD/MM/YYYY
                          String formattedDate =
                          DateFormat('dd/MM/yyyy').format(pickedDate);

                          setState(() {
                            licenseExpirationDateController.text =
                                formattedDate; // Set the formatted date to the controller
                          });
                        }
                      },
                    ),

                    SizedBox(height: 20,),
                    Text("Vehicle Details",style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkTheme ? Colors.amber.shade400 : Colors.grey
                    ),),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "Vehicle MAKE eg: Honda ",
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

                      onChanged: (text) {
                        setState(() {
                          vehicleMakeController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "Vehicle Model ",
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

                      onChanged: (text) {
                        setState(() {
                          vehicleModelController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        FilteringTextInputFormatter.digitsOnly, // Allows only numbers
                      ],
                      keyboardType: TextInputType.number, // Numeric keyboard
                      decoration: InputDecoration(
                        hintText: "Vehicle Year",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(width: 0, style: BorderStyle.none),
                        ),
                        prefixIcon: Icon(
                          Icons.directions_car, // Changed icon to car for relevance
                          color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          vehicleYearController.text = text;
                        });
                      },
                    ),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "Vehicle Color ",
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

                      onChanged: (text) {
                        setState(() {
                          vehicleColorController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      inputFormatters: [LengthLimitingTextInputFormatter(50)],
                      decoration: InputDecoration(
                        hintText: "Vehicle License Plate ",
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

                      onChanged: (text) {
                        setState(() {
                          licensePlateController.text = text;
                        });
                      }, // Removed semicolon here
                    ),
                    SizedBox(height: 10,),

                    TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        FilteringTextInputFormatter.digitsOnly, // Allows only numbers
                      ],
                      keyboardType: TextInputType.number, // Numeric keyboard
                      decoration: InputDecoration(
                        hintText: "Vehicle Capacity",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide(width: 0, style: BorderStyle.none),
                        ),
                        prefixIcon: Icon(
                          Icons.directions_car, // Changed icon to car for relevance
                          color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                        ),
                      ),
                      onChanged: (text) {
                        setState(() {
                          vehicleCapacityController.text = text;
                        });
                      },
                    ),

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
                          registerDriver();
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
