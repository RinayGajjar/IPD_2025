import 'package:drivers/Assistants/request_assistant.dart';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:drivers/Models/directions.dart';

import 'package:drivers/global/map_key.dart';
import 'package:provider/provider.dart';

import '../Models/direction_details_info.dart';
import '../Models/user_model.dart';
import '../global/global.dart';
import '../infoHandler/app_info.dart';

class AssistantMethods {
  // Read current online user's information


  // Search for an address based on geographic coordinates
  static Future<String> searchAddressForGeographicCoOrdinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if (requestResponse != "Error Occured. Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      // Update the pickup address details
      Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude= position.latitude; // Assign the double latitude
        userPickUpAddress.locationLongitude= position.longitude; // Assign the double longitude
        userPickUpAddress.locationName= humanReadableAddress; // Assign the String address


      // Uncomment the line below if using a state management solution like Provider
       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition , LatLng destinationPosition) async{

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    // if (responseDirectionApi == "Error Occured. Failed. No Response.") {
    //   return "";
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;

  }

}