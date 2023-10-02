import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ridesharing/DetailPage.dart';
import 'package:intl/intl.dart';

class DriverRideDetailsPage extends StatelessWidget {
  final String currentUserId;

  DriverRideDetailsPage(this.currentUserId);

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: StreamBuilder<QuerySnapshot>(
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

            return Column(
              children: rides.map((ride) {
                final rideId = ride.id;
                final rideData = ride.data() as Map<String, dynamic>;

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
                            Flexible(
                              // Wrap with Flexible
                              child: Text(
                                rideData['startLocation'] ?? '',
                              ),
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
                            Flexible(
                              // Wrap with Flexible
                              child: Text(
                                rideData['endLocation'] ?? '',
                              ),
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
                              DateFormat('yyyy-MM-dd ').format(rideDate),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(rideId, user!.uid),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
