import 'package:firebase_auth/firebase_auth.dart';
import 'package:ipdapp/Models/direction_details_info.dart';

import '../Models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;
UserModel? userModelCurrentInfo;

// String cloudMessagingServerToken =
// List driversList = [];

DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";

double countRatingStars = 0.0;
String titledStarsRating = "";
