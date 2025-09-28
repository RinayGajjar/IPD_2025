import 'dart:async';

import 'package:drivers/screens/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';


import '../Models/direction_details_info.dart';
import '../Models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;
DirectionDetailsInfo? tripDirectionDetailsInfo;

UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;

DriverData onlineDriverData = DriverData();

String? driverVehicleType = "";
