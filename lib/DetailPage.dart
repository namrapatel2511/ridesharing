import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatelessWidget {
  final String rideId;
  final String currentUserId; // This will be the creator's user ID

  DetailPage(this.rideId, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details (Creator)'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Ride details not found.'));
          }

          final rideData = snapshot.data!.data() as Map<String, dynamic>;
          final startLocation = rideData['startLocation'] ?? '';
          final endLocation = rideData['endLocation'] ?? '';
          final date = rideData['date'] ?? '';
          final time = rideData['time'] ?? '';
          final availableSeats = rideData['selectedSeats'] ?? 0;

          // You can also fetch the number of users who joined the ride
          // This assumes that user IDs are stored in a subcollection 'participants'
          final participantsCollection = FirebaseFirestore.instance
              .collection('rides')
              .doc(rideId)
              .collection('participants');

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text('Start Location'),
                subtitle: Text(startLocation),
              ),
              ListTile(
                title: Text('End Location'),
                subtitle: Text(endLocation),
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(date),
              ),
              ListTile(
                title: Text('Time'),
                subtitle: Text(time),
              ),
              ListTile(
                title: Text('Available Seats'),
                subtitle: Text(availableSeats.toString()),
              ),
              FutureBuilder<QuerySnapshot>(
                future: participantsCollection.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData) {
                    return ListTile(
                      title: Text('Users Who Joined'),
                      subtitle: Text('0'), // No users joined
                    );
                  }

                  final usersJoined = snapshot.data!.docs.length;
                  return ListTile(
                    title: Text('Users Who Joined'),
                    subtitle: Text(usersJoined.toString()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
