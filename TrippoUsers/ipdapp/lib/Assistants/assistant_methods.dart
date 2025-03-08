import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipdapp/Assistants/request_assistant.dart';
import 'package:ipdapp/Models/directions.dart';
import 'package:ipdapp/Models/user_model.dart';
import 'package:ipdapp/global/global.dart';
import 'package:ipdapp/global/map_key.dart';
import 'package:provider/provider.dart';
import '../Models/direction_details_info.dart';
import '../infoHandler/app_info.dart';

class AssistantMethods {

  // Read current online user's information
  // static void readCurrentOnlineUserInfo() async {
  //   currentUser = firebaseAuth.currentUser;
  //
  //   if (currentUser != null) {
  //     DatabaseReference userRef = FirebaseDatabase.instance.ref()
  //         .child("users")
  //         .child(currentUser!.uid);
  //
  //     userRef.once().then((snap) {
  //       if (snap.snapshot.value != null) {
  //         userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
  //       }
  //     });
  //   }

  // Fetch human-readable address for geographic coordinates
  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured. Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      // Update the pickup address details
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      // Update pickup location address using Provider
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  // Fetch route details from origin to destination
  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(apiUrl);

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points =
    responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distance_text =
    responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value =
    responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text =
    responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value =
    responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  // Calculate fare amount based on direction details
  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailsInfo directionDetailsInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailsInfo.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailsInfo.distance_value! / 1000) * 0.1;

    // Total fare in USD
    double totalFareAmount =
        timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(1));
  }

// (Optional) Send notification to driver
// This method is commented out for now but can be implemented as needed.
// static void sendNotificationToDriver(String deviceRegistrationToken, String userRideRequestId, context) async {
//   String destinationAddress = userDropOffAddress;
//
//   Map<String, String> headerNotification = {
//     'Content-Type': 'application/json',
//     'Authorization': cloudMessagingServerToken,
//   };
//
//   Map bodyNotification = {
//     "body": "Destination Address: \n$destinationAddress",
//   };
// }
}
