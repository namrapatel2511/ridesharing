/*import 'package:flutter/material.dart';
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

          // Create a subcollection for ride requests
          final rideRequestsCollection = FirebaseFirestore.instance
              .collection('rides')
              .doc(rideId)
              .collection('ride_requests');

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
              StreamBuilder<QuerySnapshot>(
                stream: rideRequestsCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ListTile(
                      title: Text('Ride Requests'),
                      subtitle: Text('No ride requests received.'),
                    );
                  }

                  final requests = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('Ride Requests'),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request =
                              requests[index].data() as Map<String, dynamic>;
                          final requesterName =
                              request['requesterName'] ?? 'Unknown User';
                          final pickupStand = request['pickupStand'] ?? '';
                          final seatsRequired = request['seatsRequired'] ?? 0;

                          return ListTile(
                            title: Text('Requester: $requesterName'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pickup Stand: $pickupStand'),
                                Text('Seats Required: $seatsRequired'),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
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
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatelessWidget {
  final String rideId;
  final String currentUserId; // This will be the creator's user ID

  DetailPage(this.rideId, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    // Firestore collection references
    final rideDocRef =
        FirebaseFirestore.instance.collection('rides').doc(rideId);
    final participantsCollectionRef = rideDocRef.collection('participants');
    final rideRequestsCollectionRef = rideDocRef.collection('ride_requests');

    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details (Creator)'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: rideDocRef.snapshots(),
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
                future: participantsCollectionRef.get(),
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
              StreamBuilder<QuerySnapshot>(
                stream: rideRequestsCollectionRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ListTile(
                      title: Text('Ride Requests'),
                      subtitle: Text('No ride requests received.'),
                    );
                  }

                  final requests = snapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('Ride Requests'),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final request =
                              requests[index].data() as Map<String, dynamic>;
                          final requestId = requests[index].id;

                          final requesterName =
                              request['requesterName'] ?? 'Unknown User';
                          final pickupStand = request['pickupStand'] ?? '';
                          final seatsRequired = request['seatsRequired'] ?? 0;

                          return Column(
                            children: [
                              ListTile(
                                title: Text('Requester: $requesterName'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Pickup Stand: $pickupStand'),
                                    Text('Seats Required: $seatsRequired'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check), // Accept request
                                      onPressed: () async {
                                        // Handle accepting the request here
                                        // Update the request status and increment the number of users who joined
                                        final requestDoc =
                                            rideRequestsCollectionRef
                                                .doc(requestId);
                                        await requestDoc
                                            .update({'status': 'accepted'});

                                        // Increment the number of users who joined in the main ride document
                                        final currentUsersJoined =
                                            rideData['usersJoined'] ?? 0;
                                        await rideDocRef.update({
                                          'usersJoined': currentUsersJoined + 1
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close), // Reject request
                                      onPressed: () async {
                                        // Handle rejecting the request here
                                        // You can remove the request from the collection
                                        await rideRequestsCollectionRef
                                            .doc(requestId)
                                            .delete();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // Display pickup location and seats requested for each request
                              ListTile(
                                title: Text('Pickup Stand: $pickupStand'),
                                subtitle:
                                    Text('Seats Required: $seatsRequired'),
                              ),
                              Divider(), // Add a divider to separate requests
                            ],
                          );
                        },
                      ),
                    ],
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
