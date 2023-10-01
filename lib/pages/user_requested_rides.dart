import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ride_detail.dart';

class UserRequestedRidesPage extends StatelessWidget {
  final String currentUserId;

  UserRequestedRidesPage(this.currentUserId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requested Rides'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('riderequest')
            .where('requesterId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ride requests found.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index].data() as Map<String, dynamic>;
              final rideId = request['rideId'];
              final status = request['status'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('rides')
                    .doc(rideId)
                    .get(),
                builder: (context, rideSnapshot) {
                  if (rideSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!rideSnapshot.hasData) {
                    return SizedBox.shrink();
                  }

                  final rideData =
                      rideSnapshot.data!.data() as Map<String, dynamic>;

                  final startLocation = rideData['startLocation'];
                  final endLocation = rideData['endLocation'];
                  final date = rideData['date'];

                  return Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('Start Location: $startLocation'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Location: $endLocation'),
                          Text('Date: $date'),
                          Text('Status: $status'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailedRidePage(rideId, status),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
