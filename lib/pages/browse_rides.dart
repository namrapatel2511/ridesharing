/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'RideDetailsPage.dart';

class BrowseRidesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Rides'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rides').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final rides = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index].data() as Map<String, dynamic>;
              final rideId = rides[index].id;
              final user = FirebaseAuth.instance.currentUser;
              String currentUserId = user!.uid;

              final dateStr = ride['date'];
              final currentDate = DateTime.now();
              final rideDate = DateTime.parse(dateStr);

              if (currentDate.isBefore(rideDate) ||
                  currentDate.isAtSameMomentAs(rideDate)) {
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Location:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ride['startLocation'],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'End Location:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ride['endLocation'],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Click to View Full Details',
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RideDetailsPage(rideId, currentUserId),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'RideDetailsPage.dart';

class BrowseRidesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Rides'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rides').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final rides = snapshot.data!.docs;

          // Get the current date with only the date portion
          final currentDate = DateTime.now();
          final currentDateOnly = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
          );

          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index].data() as Map<String, dynamic>;
              final rideId = rides[index].id;
              final user = FirebaseAuth.instance.currentUser;
              String currentUserId = user!.uid;

              final dateStr = ride['date'];
              final rideDate = DateFormat('yyyy-MM-dd').parse(dateStr);

              if (currentDateOnly.isBefore(rideDate) ||
                  currentDateOnly.isAtSameMomentAs(rideDate)) {
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Location:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ride['startLocation'],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'End Location:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ride['endLocation'],
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Click to View Full Details',
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RideDetailsPage(rideId, currentUserId),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
