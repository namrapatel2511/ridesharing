import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ridesharing/DetailPage.dart';
import 'package:intl/intl.dart'; // Add this import

class DriverRideDetailsPage extends StatelessWidget {
  final String currentUserId;

  DriverRideDetailsPage(this.currentUserId);

  @override
  Widget build(BuildContext context) {
    // Fetch and display all rides created by the user
    Stream<QuerySnapshot> getRidesStream() {
      return FirebaseFirestore.instance
          .collection('rides')
          .where('creatorUID', isEqualTo: currentUserId)
          .snapshots();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Rides (Driver)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getRidesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('You haven\'t created any rides.'),
            );
          }

          final user = FirebaseAuth.instance.currentUser;
          final rides = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              final rideId = ride.id;
              final rideData = ride.data() as Map<String, dynamic>;

              // Convert the date string to a DateTime object
              final dateStr = rideData['date'] as String;
              final rideDate = DateTime.parse(dateStr);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Start: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            rideData['startLocation'] ?? '',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'End: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            rideData['endLocation'] ?? '',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Date: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd ')
                                .format(rideDate), // Format the date as needed
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailPage(rideId, user!.uid), // Pass user.uid
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
