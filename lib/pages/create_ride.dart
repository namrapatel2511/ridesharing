import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _formKey = GlobalKey<FormState>();
  GoogleMapController? mapController;
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyCM8fWUE5pRL0qC4I83fJGebRnP3tdVPpQ";

  Set<Marker> markers = Set();
  Map<PolylineId, Polyline> polylines = {};

  TextEditingController startLocationController = TextEditingController();
  TextEditingController endLocationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  double selectedSeats = 1; // Default value

  LatLng startLocation = const LatLng(0, 0);
  LatLng endLocation = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
  }

  String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required!';
    }
    return null;
  }

  Future<void> _searchPlace(String placeName, bool isStartLocation) async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: googleAPiKey,
      mode: Mode.overlay,
      types: [],
      strictbounds: false,
      onError: (err) {
        print(err);
      },
    );

    if (p != null) {
      final places = GoogleMapsPlaces(
        apiKey: googleAPiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      final placeDetail = await places.getDetailsByPlaceId(p.placeId!);
      final geometry = placeDetail.result.geometry!;
      final lat = geometry.location.lat;
      final lng = geometry.location.lng;
      final newLatLng = LatLng(lat, lng);

      setState(() {
        if (isStartLocation) {
          startLocationController.text = p.description!;
          startLocation = newLatLng;
          markers.removeWhere((marker) => marker.markerId.value == 'start');
          markers.add(
            Marker(
              markerId: const MarkerId('start'),
              position: startLocation,
              infoWindow: const InfoWindow(
                title: 'Starting Point',
                snippet: 'Start Marker',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        } else {
          endLocationController.text = p.description!;
          endLocation = newLatLng;
          markers.removeWhere((marker) => marker.markerId.value == 'end');
          markers.add(
            Marker(
              markerId: const MarkerId('end'),
              position: endLocation,
              infoWindow: const InfoWindow(
                title: 'Destination Point',
                snippet: 'Destination Marker',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        }

        mapController
            ?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 12.0));

        getDirections();
      });
    }
  }

  getDirections() async {
    List<LatLng> polylineCoordinates = [];

    final PolylineResult result =
        await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  _selectDate(BuildContext context) async {
    final DateTime pickedDate = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;
    if (pickedDate != null && pickedDate != DateTime.now()) {
      dateController.text = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay pickedTime = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ))!;
    if (pickedTime != null && pickedTime != TimeOfDay.now()) {
      timeController.text = pickedTime.format(context);
    }
  }

  Future<void> _createRide() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
            .collection('profiles')
            .doc(user.uid)
            .get();

        if (!profileSnapshot.exists ||
            profileSnapshot['fullName'] == null ||
            profileSnapshot['number'] == null) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Profile Incomplete'),
                content: Text(
                    'Please complete your profile before creating a ride.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return;
        }

        final rideData = {
          'startLocation': startLocationController.text,
          'endLocation': endLocationController.text,
          'date': dateController.text,
          'time': timeController.text,
          'selectedSeats': selectedSeats.toInt(),
          'creatorUID': user.uid,
        };

        try {
          final firestore = FirebaseFirestore.instance;
          await firestore.collection('rides').add(rideData);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Ride Created'),
                content: Text('Your ride has been created successfully.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } catch (e) {
          print('Error creating ride: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Route Direction in Google Map"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              child: GoogleMap(
                zoomGesturesEnabled: true,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 0.0,
                ),
                markers: markers,
                polylines: Set<Polyline>.of(polylines.values),
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          startLocationController,
                          "Start Location",
                          Icons.location_on,
                          onTap: () =>
                              _searchPlace(startLocationController.text, true),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: _buildInputField(
                          endLocationController,
                          "End Location",
                          Icons.location_on,
                          onTap: () =>
                              _searchPlace(endLocationController.text, false),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          dateController,
                          "Date",
                          Icons.calendar_today,
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: _buildInputField(
                          timeController,
                          "Time",
                          Icons.access_time,
                          onTap: () => _selectTime(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  _buildSliderField(
                    selectedSeats as double,
                    "Number of Seats",
                    Icons.event_seat,
                    onChanged: (double newValue) {
                      setState(() {
                        selectedSeats = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _createRide,
                    child: Text('Create Ride'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String labelText,
    IconData iconData, {
    Function()? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        onTap: onTap,
        validator: validateLocation,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(iconData),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  Widget _buildSliderField(
    double selectedValue,
    String labelText,
    IconData iconData, {
    ValueChanged<double>? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(iconData),
          const SizedBox(width: 12),
          Expanded(
            child: Slider(
              value: selectedValue,
              onChanged: onChanged,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              label: selectedValue.toInt().toString(),
            ),
          ),
        ],
      ),
    );
  }
}
