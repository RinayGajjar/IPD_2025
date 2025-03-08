import 'dart:async';
import 'dart:convert';

//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ipdapp/Assistants/assistant_methods.dart';
import 'package:ipdapp/Assistants/geofire_assistant.dart';
import 'package:ipdapp/Models/active_nearby_available_drivers.dart';
import 'package:ipdapp/global/global.dart';
import 'package:ipdapp/global/map_key.dart';
import 'package:ipdapp/infoHandler/app_info.dart';
import 'package:ipdapp/screens/drawer_screen.dart';
import 'package:ipdapp/screens/precise_pickup_location.dart';
import 'package:ipdapp/screens/search_places_screen.dart';
import 'package:ipdapp/splashscreen/splash_screen.dart';
import 'package:ipdapp/widgets/progress_dialog.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Models/directions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen ({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;
  String id = "Fetching ID...";
  String rideStatus = "";

  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "";
  String userEmail = "";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  double distance = 0;
  int duration = 0;
  double fare = 0;



  String selectedVehicleType = "";

  String driverRideStatus = "Driver is coming";


  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriversList = [];

  String userRideRequestStatus = "";

  bool requestPositionInfo = true;

  String otp = "Tap to Get OTP";


  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(
        userCurrentPosition!, context);
    print("This is our address = " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();


  }



  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
    .listen((map) {
      print(map);
      if(map != null) {
       var callBack = map["callBack"];

       switch(callBack) {
         // whenever any driver become active or online
         case Geofire.onKeyEntered:
           ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
           activeNearByAvailableDrivers.locationLatitude = map["latitude"];
           activeNearByAvailableDrivers.locationLongitude = map["longitude"];
           activeNearByAvailableDrivers.driverId = map["key"];
           GeoFireAssistant.activeNearByAvailableDriversList.add(activeNearByAvailableDrivers);
           if(activeNearbyDriverKeysLoaded == true){
             displayActiveDriversOnUserMap();
           }
           break;
           //whenever driver moves - update driver location
         case Geofire.onKeyExited:
           GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);
           displayActiveDriversOnUserMap();
           break;
           //whenever driver moves - update driver location
         case Geofire.onKeyMoved :
           ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
           activeNearByAvailableDrivers.locationLatitude = map["latitude"];
           activeNearByAvailableDrivers.locationLongitude = map["longitude"];
           activeNearByAvailableDrivers.driverId = map["key"];
           GeoFireAssistant.updateActiveNearByAvailableDriverLocation(activeNearByAvailableDrivers);
           displayActiveDriversOnUserMap();
           break;

           //display those online active drivers on users map
         case Geofire.onGeoQueryReady:
           activeNearbyDriverKeysLoaded = true;
           displayActiveDriversOnUserMap();
           break;
       }
      }

      setState(() {

      });

    });
  }

  displayActiveDriversOnUserMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for(ActiveNearByAvailableDrivers eachDriver in GeoFireAssistant.activeNearByAvailableDriversList){
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driversMarkerSet;
      });

    });
  }

  createActiveNearByDriverIconMarker(){
    if(activeNearbyIcon == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, 'images/car.png').then((value){
        activeNearbyIcon = value;
      });
    }
  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async{
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition!.locationLongitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if(decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng){
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
      );
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
        markerId: MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

  }

  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  void showSuggestedRidesContainer(){
    setState(() {
      suggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }


  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.checkPermission();

    // If permission is denied or denied forever, request permission
    if (_locationPermission == LocationPermission.denied ||
        _locationPermission == LocationPermission.deniedForever) {
      _locationPermission = await Geolocator.requestPermission();

      // Check again after requesting
      if (_locationPermission == LocationPermission.denied ||
          _locationPermission == LocationPermission.deniedForever) {
        print("Location permission denied or permanently denied.");
        return; // Exit the method if permissions are not granted
      }
    }

    // If permission is granted, log a confirmation
    print("Location permission granted.");
  }



  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if(requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPickUpPosition = LatLng(userCurrentPosition!.longitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userPickUpPosition,
      );

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Driver is coming: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async{
    if(requestPositionInfo == true){
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(dropOffLocation!.locationLatitude!, dropOffLocation.locationLongitude!);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userDestinationPosition
      );

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Going towards Destination: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  Future<void> fetchUserProfileid() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      if (jwt == null) {
        setState(() {

          id = "Not Authenticated";
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5454/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);

        int? userId = data['id'];
        if (userId != null) {
          await prefs.setInt('user_id', userId); // Store driver_id
          print("User ID stored successfully: $userId");
        }
      }
    }catch (e) {
      print("Exception: $e");
    }
  }

  void _setErrorState(String errorMessage) {
    id = errorMessage;
  }



  Future<void> requestRide(BuildContext context, String jwtToken) async {
    try {
      final url = Uri.parse('http://10.0.2.2:5454/api/rides/request');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Include the token here.
      };

      final body = jsonEncode({
        'pickupArea': Provider.of<AppInfo>(context, listen: false).userPickUpLocation!.locationName!,
        'destinationArea': Provider.of<AppInfo>(context, listen: false).userDropOffLocation!.locationName!,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 202) {
        final responseData = jsonDecode(response.body);

        // Save ride ID for further use.
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('ride_id', responseData['id']);

        Fluttertoast.showToast(msg: 'Ride requested successfully!');

        setState(() {
          suggestedRidesContainerHeight = 0;
          bottomPaddingOfMap = 0;
        });

      } else {
        final responseData = jsonDecode(response.body);
        Fluttertoast.showToast(msg: 'Error: ${responseData['message']}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred: $e');
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponsefromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  Future<void> fetchUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jwt = prefs.getString('jwt');

      if (jwt == null) {

        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5454/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);

        ;
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        ;
      }
    } catch (e) {
      print("Exception: $e");
      ;
    }
  }

  Future<void> fetchRideOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final rideId = prefs.getInt('ride_id');  // Retrieve ride ID from SharedPreferences
    final jwt = prefs.getString('jwt');  // Retrieve JWT token

    if (rideId == null || jwt == null) {
      setState(() {
        otp = "Ride ID or JWT not found";
      });
      return;
    }

    try {
      // API call to get OTP
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5454/api/rides/$rideId"),
        headers: {"Authorization": "Bearer $jwt"},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final otpData = jsonDecode(response.body);
        setState(() {
          otp = "Your OTP: ${otpData["otp"]}";
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          otp = "Error: ${responseData['message']}";
        });
      }
    } catch (e) {
      setState(() {
        otp = "An error occurred: $e";
      });
    }
  }

  Future<void> fetchRideStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final rideId = prefs.getInt('ride_id');  // Retrieve ride ID from SharedPreferences
    final jwt = prefs.getString('jwt');  // Retrieve JWT token

    if (rideId == null || jwt == null) {
      setState(() {
        otp = "Ride ID or JWT not found";
      });
      return;
    }

    try {
      // API call to get OTP
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5454/api/rides/$rideId"),
        headers: {"Authorization": "Bearer $jwt"},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        setState(() {
          rideStatus = data['status'];
        });
      } else {

        setState(() {
          print("Failed to fetch ride details");
        });
      }
    } catch (e) {
      setState(() {
        print("An error occurred: $e");
      });
    }
  }



  Future<void> fetchRideDetails(String rideId) async {
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');

    if (jwt == null) {
      print("JWT not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5454/api/rides/$rideId"),
        headers: {"Authorization": "Bearer $jwt"},
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        final data = jsonDecode(response.body);
        setState(() {
          rideStatus = data['status'];
          distance = data['distance'].toDouble();
          duration = data['duration'];
          fare = data['fare'].toDouble();
        });
        showRideDetails();
      } else {
        print("Failed to fetch ride details");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }


  void showRideDetails() {
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
                "Ride Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Text("Distance: ${distance.toStringAsFixed(2)} km", style: TextStyle(fontSize: 16)),
              Text("Duration: $duration min", style: TextStyle(fontSize: 16)),
              Text("Fare: ₹$fare", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Okay"),
                ),
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
    fetchUserProfileid();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    createActiveNearByDriverIconMarker();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 30, bottom: bottomPaddingOfMap),
              mapType: MapType.normal ,
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

                setState(() {
                  bottomPaddingOfMap = 200;
                });

                locateUserPosition();
              },

            ),
            Positioned(
                top: 50,
              left: 30,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: darkTheme ? Colors.black : Colors.lightBlue,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Ride Status: $rideStatus", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  if (rideStatus == "ACCEPTED")
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Ride Accepted")),
                        );
                      },
                      child: Text("Ride Accepted"),
                    ),
                ],
              ),
            ),

            //ui for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: darkTheme ?
                                        Colors.amber.shade400 : Colors.blue
                                        ,),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("From",
                                          style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                          fontSize: 14, fontWeight: FontWeight.bold,
                                          ),
                                          ),
                                          Text(Provider.of<AppInfo>(context).userPickUpLocation!= null ? (
                                              Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..."
                                                     : "Not Getting Address",
                                          style: TextStyle(color: Colors.grey,fontSize: 14),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5,),

                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue
                                ),
                                SizedBox(height: 5,),

                                Padding(
                                    padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async{
                                      //go to search places screen
                                      var responseFromsearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPlacesScreen()));

                                      if(responseFromsearchScreen == "obtainedDropoff"){
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      await drawPolyLineFromOriginToDestination(darkTheme);

                                    },
                                    child:Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, color: darkTheme ?
                                        Colors.amber.shade400 : Colors.blue
                                          ,),
                                        SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("To",
                                              style: TextStyle(color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                                fontSize: 14, fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(Provider.of<AppInfo>(context).userDropOffLocation != null ?
                                                Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                                : "Where to?",
                                              style: TextStyle(color: Colors.grey,fontSize: 14),
                                            )
                                          ],
                                        )
                                      ],
                                    ) ,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 5,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => PrecisePickupScreen()));
                                },
                                child: Text(
                                  "Change Pick Up address",
                                  style: TextStyle(
                                    color: darkTheme ? Colors.black : Colors.white,
                                  ),
                                ),

                                style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )
                                ),
                              ),

                              SizedBox(width: 10,),

                              ElevatedButton(
                                onPressed: () {
                                  if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null){
                                    showSuggestedRidesContainer();
                                  }
                                  else{
                                    Fluttertoast.showToast(msg: "Please select destination location");
                                  }
                                },
                                child: Text(
                                  "Show Fare",
                                  style: TextStyle(
                                    color: darkTheme ? Colors.black : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )
                                ),
                              ),
                            ],
                          )
                        ],

                      ),
                    ),
                  ],
                ),
              ),
            ),


            Positioned(
              bottom: 100, // Adjust as needed
              left: 50, // Adjust as needed
              right: 50, // Adjust as needed
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: fetchRideOtp                                                     ,
                    child: Text("Get Ride OTP"),
                  ),
                  SizedBox(height: 20),
                  Text(
                    otp,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: suggestedRidesContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  )
                ),
                child: Padding(
                    padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 15,),

                          Text(
                            Provider.of<AppInfo>(context).userPickUpLocation!= null ? (
                                Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..."
                                : "Not Getting Address",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 20,),

                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 15,),

                          Text(
                            Provider.of<AppInfo>(context).userDropOffLocation != null ?
                                Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                : "Where to?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 20,),

                      Text("SUGGESTED RIDES",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      ),

                      SizedBox(height: 20,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "Car";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Car" ? (darkTheme ? Colors.amber.shade400 : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                  padding: EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "images/car.png",
                                      width: 80, // Limit the width of the image
                                      height: 80, // Limit the height of the image
                                      fit: BoxFit.contain, // Ensures the image fits within the given width/height
                                    ),

                                    SizedBox(height: 8,),

                                    Text(
                                        "Car",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Car" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    SizedBox(height: 2,),

                                    Text(
                                    tripDirectionDetailsInfo != null ? "₹ ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 2) * 60).toStringAsFixed(1)}"
                                    : "null",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "CNG";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "CNG" ? (darkTheme ? Colors.amber.shade400 : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "images/cng.png",
                                      width: 80, // Limit the width of the image
                                      height: 80, // Limit the height of the image
                                      fit: BoxFit.contain, // Ensures the image fits within the given width/height
                                    ),

                                    SizedBox(height: 8,),

                                    Text(
                                      "CNG",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "CNG" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    SizedBox(height: 2,),

                                    Text(
                                      tripDirectionDetailsInfo != null ? "₹ ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 1.5) * 60).toStringAsFixed(1)}"
                                          : "null",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "Bike";
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Bike" ? (darkTheme ? Colors.amber.shade400 : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "images/bike.png",
                                      width: 80, // Limit the width of the image
                                      height: 80, // Limit the height of the image
                                      fit: BoxFit.contain, // Ensures the image fits within the given width/height
                                    ),

                                    SizedBox(height: 8,),

                                    Text(
                                      "bike",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "bike" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    SizedBox(height: 2,),

                                    Text(
                                      tripDirectionDetailsInfo != null ? "₹ ${((AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) * 0.8) * 60).toStringAsFixed(1)}"
                                          : "null",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: 20,),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if(selectedVehicleType != ""){
                              //saveRideRequestInformation(selectedVehicleType);
                            }
                            else{
                              Fluttertoast.showToast(msg: "Please select a vehicle from \n suggested rides. ");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: darkTheme? Colors.amber.shade400 : Colors.blue,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(
                              child:ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  final String? jwtToken = prefs.getString('jwt'); // Fetch the saved JWT token.

                                  if (jwtToken != null) {
                                    await requestRide(context, jwtToken);
                                  } else {
                                    Fluttertoast.showToast(msg: 'Please log in to continue.');
                                  }
                                },
                                child: Text('Request Ride'),
                              )
                            ),
                          ),
                        ),
                      )

                    ],
                  ),

                ),
              ),
            )

            // Positioned(
            //   top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.all(20),
            //     child: Text(
            //       Provider.of<AppInfo>(context).userPickUpLocation != null ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..."
            //           : "Not Getting Address",
            //     overflow: TextOverflow.visible, softWrap: true,
            //     ),
            //
            //   ),
            // )



          ],
        ),
      ),
    );
  }
}
