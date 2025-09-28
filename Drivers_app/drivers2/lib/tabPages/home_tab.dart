import 'dart:async';
import 'dart:convert';

import 'package:drivers/Models/directions.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Assistants/assistant_methods.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {

  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  var geolocator = Geolocator();

  Directions driverLocation= Directions();
  Directions pickup= Directions();
  Directions destination= Directions();

  LocationPermission? _locationPermission;
  String? pickupLocation;
  String? destinationLocation;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  bool showOtpField = false;
  bool showCompleteButton = false;
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  String statusText = "Now Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.checkPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;

    LatLng driverLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: driverLatLng, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(
        driverCurrentPosition!, context);
    print("This is our address = " + humanReadableAddress);

     driverLocation = Directions(
      locationLatitude: driverLatLng.latitude,
      locationLongitude: driverLatLng.longitude,
      locationName: humanReadableAddress
    );

}
  Future<void> fetchRideDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Retrieve stored driver ID and JWT token
      String? jwt = prefs.getString('jwt');
      int? driverId = prefs.getInt('driver_id');

      if (jwt == null || driverId == null) {
        print("Driver ID or JWT token not found");
        return;
      }

      // API request to fetch ride details
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5454/api/drivers/$driverId/allocated'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        saveLatLngFromResponse(data);

        if (data == null || data['pickupArea'] == null || data['destinationArea'] == null) {
          print("No ride allocated or incomplete data received.");
          return;
        }

        // Extract ride details
        int? rideId = data['id'];
        String pickup = data['pickupArea'] ?? "Pickup location not found";
        String destination = data['destinationArea'] ?? "Destination location not found";
        double fare = (data['fare'] ?? 0).toDouble();


        setState(() {
          pickupLocation = pickup;

          destinationLocation = destination;
        });

        if (rideId != null) {
          await prefs.setInt('ride_id', rideId);
          print("Ride ID stored successfully: $rideId");

          // Show ride request modal when a ride is assigned
          showRideRequest();
        }
      } else {
        print("Error fetching ride: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception in fetchRideDetails: $e");
    }
  }


  Future<void> startRide() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? driverJwt = prefs.getString('jwt');
    int? rideId = prefs.getInt('ride_id');

    if (driverJwt == null || rideId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Missing authentication or ride details")));
      return;
    }

    setState(() {
      //isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:5454/api/rides/$rideId/start');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $driverJwt',
      },
      body: jsonEncode({"otp": int.tryParse(otpController.text)}),
    );



      //isLoading = false;
      if (response.statusCode == 200 || response.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ride started successfully")));
        showOtpField = false;
        showCompleteButton = true;
        if (driverLocation != null && pickup != null) {
          await drawPolyLineFromOriginToDestination(
          pickup: driverLocation,
          destination: destination,
          darkTheme: false,
          );
          // Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: "Driver or Pickup location is missing.");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to start ride: ${response.body}")));
      }
    ;
  }

  Future<void> completeRide() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? driverJwt = prefs.getString('jwt');
    int? rideId = prefs.getInt('ride_id');

    if (driverJwt == null || rideId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Missing authentication or ride details")));
      return;
    }

    final url = Uri.parse('http://10.0.2.2:5454/api/rides/$rideId/complete');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $driverJwt',
      },
    );

    setState(() {
      if (response.statusCode == 200 || response.statusCode == 202) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ride completed successfully")));
        showCompleteButton = false;
        showOtpField = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to complete ride: ${response.body}")));
      }
    });
  }
  void saveLatLngFromResponse (Map<String, dynamic> response)async {
     pickup = Directions(
      locationLatitude: response["pickupLatitude"],
      locationLongitude: response["pickupLongitude"],
      locationName: response["pickupArea"],
    );

     destination = Directions(
      locationLatitude: response["destinationLatitude"],
      locationLongitude: response["destinationLongitude"],
      locationName: response["destinationArea"],
    );

// Call the polyline method
//     await drawPolyLineFromOriginToDestination(
//     pickup: pickup,
//     destination: destination,
//     darkTheme: false,
//     );
  }

  Future<void> drawPolyLineFromOriginToDestination({
    required Directions pickup,
    required Directions destination,
    required bool darkTheme,
  }) async {
    final originLatLng = LatLng(pickup.locationLatitude!, pickup.locationLongitude!);
    final destinationLatLng = LatLng(destination.locationLatitude!, destination.locationLongitude!);

    // 1. Get route details
    final directionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
      originLatLng,
      destinationLatLng,
    );

    if (directionDetails == null || directionDetails.e_points == null) return;

    setState(() {
      tripDirectionDetailsInfo = directionDetails;
    });

    // 2. Decode polyline
    List<PointLatLng> decodedPoints = PolylinePoints().decodePolyline(directionDetails.e_points!);
    List<LatLng> polylineCoordinates = decodedPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    // 3. Draw polyline
    setState(() {
      pLineCoOrdinatesList.clear();
      pLineCoOrdinatesList.addAll(polylineCoordinates);

      polyLineSet.clear();
      polyLineSet.add(
        Polyline(
          polylineId: PolylineId("route"),
          color: darkTheme ? Colors.amberAccent : Colors.blue,
          points: polylineCoordinates,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
        ),
      );
    });

    // 4. Adjust camera bounds
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        originLatLng.latitude <= destinationLatLng.latitude ? originLatLng.latitude : destinationLatLng.latitude,
        originLatLng.longitude <= destinationLatLng.longitude ? originLatLng.longitude : destinationLatLng.longitude,
      ),
      northeast: LatLng(
        originLatLng.latitude > destinationLatLng.latitude ? originLatLng.latitude : destinationLatLng.latitude,
        originLatLng.longitude > destinationLatLng.longitude ? originLatLng.longitude : destinationLatLng.longitude,
      ),
    );

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 65));

    // 5. Markers
    setState(() {
      markersSet.clear();
      markersSet.add(
        Marker(
          markerId: MarkerId("origin"),
          position: originLatLng,
          infoWindow: InfoWindow(title: pickup.locationName ?? "Origin"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      markersSet.add(
        Marker(
          markerId: MarkerId("destination"),
          position: destinationLatLng,
          infoWindow: InfoWindow(title: destination.locationName ?? "Destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Circles
      circlesSet.clear();
      circlesSet.add(
        Circle(
          circleId: CircleId("originCircle"),
          center: originLatLng,
          radius: 12,
          fillColor: Colors.green,
          strokeWidth: 3,
          strokeColor: Colors.white,
        ),
      );
      circlesSet.add(
        Circle(
          circleId: CircleId("destinationCircle"),
          center: destinationLatLng,
          radius: 12,
          fillColor: Colors.red,
          strokeWidth: 3,
          strokeColor: Colors.white,
        ),
      );
    });
  }


  // getAddressFromLatLng() async{
  //   try {
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: pickupLocation!.latitude,
  //         longitude: pickupLocation!.longitude,
  //         googleMapApiKey: mapKey
  //     );
  //     setState(() {
  //       Directions userPickUpAddress = Directions();
  //       userPickUpAddress.locationLatitude= pickLocation!.latitude; // Assign the double latitude
  //       userPickUpAddress.locationLongitude= pickLocation!.longitude; // Assign the double longitude
  //       userPickUpAddress.locationName= data.address;
  //
  //       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //
  //       //_address = data.address;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> acceptRide(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? rideId = prefs.getInt('ride_id');
    String? jwtToken = prefs.getString('jwt');

    if (rideId == null || jwtToken == null) {
      Fluttertoast.showToast(msg: "Ride ID or Token is missing.");
      setState(() {});
      return;
    } else {
      print("Ride Id : $rideId");
    }

    final url = Uri.parse("http://10.0.2.2:5454/api/rides/$rideId/accept");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };

    try {
      final response = await http.put(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 202) {
        Fluttertoast.showToast(msg: "Ride accepted successfully!");
        setState(() {});

        // Ensure driverLocation and pickup are not null
        if (driverLocation != null && pickup != null) {
          await drawPolyLineFromOriginToDestination(
            pickup: driverLocation,
            destination: pickup,
            darkTheme: false,
          );
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: "Driver or Pickup location is missing.");
        }
      } else {
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(msg: "Failed to accept ride: ${responseData['message']}");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "An error occurred: $error");
    }
  }

  void rejectRide(BuildContext context) {
    Navigator.pop(context);
    print("Ride Rejected!");
  }

  void showRideRequest() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Ride Request",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Text("Pickup: $pickupLocation", style: TextStyle(fontSize: 16)),
              Text("Dropoff: $destinationLocation", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => acceptRide(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("Accept", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => rejectRide(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text("Reject", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissionAllowed();
    //readCurrentDriverInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          initialCameraPosition: _kGooglePlex,
          polylines: polyLineSet,
          markers: markersSet,
          circles: circlesSet,
          onMapCreated: (GoogleMapController controller) {
            _controllerGoogleMap.complete(controller);
            newGoogleMapController = controller;
            locateDriverPosition();
          },
        ),

        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Column(
            children: [
              if (!showCompleteButton) ...[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showOtpField = true;
                    });
                  },
                  child: Text("Enter OTP"),
                ),
              ],
              if (showOtpField)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: "Enter OTP"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: isLoading ? null : startRide,
                        child: isLoading ? CircularProgressIndicator() : Text("Submit OTP"),
                      ),
                    ],
                  ),
                ),
              if (showCompleteButton)
                ElevatedButton(
                  onPressed: completeRide,
                  child: Text("Complete Ride"),
                ),
            ],
          ),
        ),

        // Button for online/offline toggle
        Positioned(
          bottom: 50,
          left: MediaQuery.of(context).size.width * 0.3, // Centering the button
          child: ElevatedButton(
            onPressed: () {
              fetchRideDetails();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Allocated Ride",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }




  updateDriversLocationatRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((Position position) {
      if(isDriverActive == true){
        Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      }

      LatLng latLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }



}
