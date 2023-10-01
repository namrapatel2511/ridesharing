import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailedRidePage extends StatelessWidget {
  final String rideId;
  final String status;

  DetailedRidePage(this.rideId, this.status);

  @override
  Widget build(BuildContext context) {
    // Retrieve ride details and display them along with the status
    // You can use the rideId to fetch ride details from Firestore
    // and display them on this page.
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Ride'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Ride details not found.'));
          }

          final rideData = snapshot.data!.data() as Map<String, dynamic>;

          // Display ride details and status here
          // You can use the `status` variable to show whether the ride is accepted, rejected, or pending.

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Display ride details here
                // For example, rideData['startLocation'], rideData['endLocation'], etc.

                Text('Status: $status'), // Display the status
              ],
            ),
          );
        },
      ),
    );
  }
}
