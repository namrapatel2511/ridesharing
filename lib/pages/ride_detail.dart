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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Ride'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('rides')
            .doc(widget.rideId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Ride details not found.'));
          }

          final rideData = snapshot.data!.data() as Map<String, dynamic>;

          final liveLocationData = rideData['liveLocation'];

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Status: ${widget.status}'),
                SizedBox(height: 16),
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
                    markers: _buildMarkers(liveLocationData),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build map markers from live location data
  Set<Marker> _buildMarkers(Map<String, dynamic> liveLocationData) {
    // Implement logic to convert live location data to markers
    // Example:
    final markers = <Marker>{};
    liveLocationData.forEach((userId, location) {
      final lat = location['latitude'] as double;
      final lng = location['longitude'] as double;
      final marker = Marker(
        markerId: MarkerId(userId),
        position: LatLng(lat, lng),
        // Add other marker properties as needed
      );
      markers.add(marker);
    });
    return markers;
  }
}
