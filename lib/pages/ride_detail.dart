import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DetailedRidePage extends StatefulWidget {
  final String rideId;
  final String status;

  DetailedRidePage(this.rideId, this.status);

  @override
  _DetailedRidePageState createState() => _DetailedRidePageState();
}

class _DetailedRidePageState extends State<DetailedRidePage> {
  GoogleMapController? _controller;
  Map<String, dynamic> liveLocationData = {};
  bool isLoading = false;
  LatLng? markerPosition;
  String requestStatus = '';

  @override
  void initState() {
    super.initState();

    _fetchRequestStatus();
  }

  void _fetchRequestStatus() async {
    try {
      final rideRequestQuerySnapshot = await FirebaseFirestore.instance
          .collection('riderequest')
          .where('rideId', isEqualTo: widget.rideId)
          .get();

      if (rideRequestQuerySnapshot.docs.isNotEmpty) {
        final rideRequestData =
            rideRequestQuerySnapshot.docs.first.data() as Map<String, dynamic>;
        final requestStatus = rideRequestData['status'] ?? '';
        setState(() {
          this.requestStatus = requestStatus;
        });
      }
    } catch (e) {
      print('Error fetching request status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Ride'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Status: ${widget.status}'),
            SizedBox(height: 16),
            if (requestStatus == 'accepted')
              Container(
                height: 300,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      _controller = controller;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(0, 0), // Initial position
                    zoom: 12,
                  ),
                  markers: _buildMarkers(),
                ),
              ),
            SizedBox(height: 16),
            if (requestStatus == 'accepted')
              ElevatedButton(
                onPressed: () {
                  _fetchLiveLocationData();
                },
                child: isLoading
                    ? CircularProgressIndicator()
                    : Text('Live Location'),
              ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (markerPosition != null) {
      final marker = Marker(
        markerId: MarkerId('userid'),
        position: markerPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      markers.add(marker);
    }
    return markers;
  }

  void _fetchLiveLocationData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('ride_navigation')
          .doc(widget.rideId)
          .get();

      if (snapshot.exists) {
        print('Live location data retrieved: ${snapshot.data()}');
        final data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          liveLocationData = data;
          final latitude = data['latitude'] as double;
          final longitude = data['longitude'] as double;
          markerPosition = LatLng(latitude, longitude);
        });
        print('Live location data updated: $liveLocationData');
        _moveCameraToMarker();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Live location data not found.'),
          ),
        );
      }
    } catch (e) {
      print('Error fetching live location data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching live location data.'),
        ),
      );
    }
  }

  void _moveCameraToMarker() {
    if (_controller != null && markerPosition != null) {
      _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: markerPosition!,
            zoom: 15,
          ),
        ),
      );
    }
  }
}
