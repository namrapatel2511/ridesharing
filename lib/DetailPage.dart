import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart';

class DetailPage extends StatefulWidget {
  final String rideId;
  final String currentUserId;

  DetailPage(this.rideId, this.currentUserId);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late DocumentReference rideDocRef;
  final participantsCollectionRef =
      FirebaseFirestore.instance.collection('participants');
  final rideRequestsCollectionRef =
      FirebaseFirestore.instance.collection('riderequest');
  final rideNavigationCollectionRef =
      FirebaseFirestore.instance.collection('ride_navigation');

  LocationData? currentLocation;

  final Location location = Location();

  String endLocation = '';
  bool isLocationLoading = false;

  List<String> waypoints = [];

  @override
  void initState() {
    super.initState();

    rideDocRef =
        FirebaseFirestore.instance.collection('rides').doc(widget.rideId);

    fetchEndLocation();
    getLocation();
  }

  void fetchEndLocation() async {
    try {
      final rideData = await rideDocRef.get();
      final endLocationData = rideData['endLocation'];
      setState(() {
        endLocation = endLocationData;
      });
    } catch (e) {
      print('Error fetching endLocation: $e');
    }
  }

  Future<void> getLocation() async {
    setState(() {
      isLocationLoading = true;
    });

    try {
      final LocationData _locationData = await location.getLocation();
      setState(() {
        currentLocation = _locationData;
        isLocationLoading = false;
      });

      storeNavigationData(
          widget.rideId, currentLocation?.latitude, currentLocation?.longitude);
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        isLocationLoading = false;
      });
    }
  }

  void storeNavigationData(
      String rideId, double? latitude, double? longitude) async {
    if (latitude != null && longitude != null) {
      try {
        final Timestamp timestamp = Timestamp.now();
        await rideNavigationCollectionRef.doc(rideId).set({
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': timestamp,
        });
      } catch (e) {
        print('Error storing navigation data: $e');
      }
    }
  }

  void openGoogleMapsNavigation(
      String startLocation, String endLocation, List<String> waypoints) async {
    final StringBuffer googleMapsUrl = StringBuffer(
        'https://www.google.com/maps/dir/?api=1&origin=$startLocation&destination=$endLocation');

    if (waypoints.isNotEmpty) {
      googleMapsUrl.write('&waypoints=${waypoints.join('|')}');
    }

    if (await canLaunch(googleMapsUrl.toString())) {
      await launch(googleMapsUrl.toString());
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          final date = rideData['date'] ?? '';
          final time = rideData['time'] ?? '';
          final availableSeats = rideData['selectedSeats'] ?? 0;
          final seatsOccupied = rideData['seatsOccupied'] ?? 0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ride Details'),
                          SizedBox(height: 16),
                          Text('Start Location: $startLocation'),
                          Text('End Location: $endLocation'),
                          Text('Date: $date'),
                          Text('Time: $time'),
                          Text('Available Seats: $availableSeats'),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: ExpansionTile(
                      title: Text('Ride Requests'),
                      initiallyExpanded: false,
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: rideRequestsCollectionRef
                              .where('rideId', isEqualTo: widget.rideId)
                              .where('status', isNotEqualTo: 'rejected')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return ListTile(
                                title: Text('No ride requests received.'),
                              );
                            }

                            final requests = snapshot.data!.docs;

                            waypoints.clear();

                            for (final request in requests) {
                              final requestStatus = request['status'];

                              if (requestStatus == 'accepted') {
                                final pickupStand =
                                    (request['pickupStand'] ?? '').toString();
                                waypoints.add(pickupStand);
                              }
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: requests.length,
                              itemBuilder: (context, index) {
                                final request = requests[index].data()
                                    as Map<String, dynamic>;
                                final requestId = requests[index].id;

                                final requesterName =
                                    request['requesterName'] ?? 'Unknown User';
                                final pickupStand =
                                    request['pickupStand'] ?? '';
                                final seatsRequired =
                                    request['seatsRequired'] ?? 0;

                                final requestStatus = request['status'];

                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text('Requester: $requesterName'),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Pickup Stand: $pickupStand'),
                                        Text('Seats Required: $seatsRequired'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (requestStatus != 'accepted')
                                          IconButton(
                                            icon: Icon(Icons.check),
                                            onPressed: () async {
                                              final requestDoc =
                                                  rideRequestsCollectionRef
                                                      .doc(requestId);
                                              await requestDoc.update(
                                                  {'status': 'accepted'});

                                              final currentUsersJoined =
                                                  rideData['usersJoined'] ?? 0;
                                              final updatedSeatsOccupied =
                                                  seatsOccupied + seatsRequired;
                                              final updatedAvailableSeats =
                                                  availableSeats -
                                                      seatsRequired;

                                              await rideDocRef.update({
                                                'usersJoined':
                                                    currentUsersJoined + 1,
                                                'seatsOccupied':
                                                    updatedSeatsOccupied,
                                                'selectedSeats':
                                                    updatedAvailableSeats,
                                              });
                                            },
                                          ),
                                        IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () async {
                                            final requestDoc =
                                                rideRequestsCollectionRef
                                                    .doc(requestId);
                                            await requestDoc
                                                .update({'status': 'rejected'});

                                            final updatedSeatsOccupied =
                                                seatsOccupied - seatsRequired;
                                            final updatedAvailableSeats =
                                                availableSeats + seatsRequired;

                                            await rideDocRef.update({
                                              'seatsOccupied':
                                                  updatedSeatsOccupied,
                                              'selectedSeats':
                                                  updatedAvailableSeats,
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: isLocationLoading
          ? CircularProgressIndicator()
          : FloatingActionButton.extended(
              onPressed: () {
                if (currentLocation != null) {
                  if (waypoints.isNotEmpty) {
                    openGoogleMapsNavigation(
                      '${currentLocation?.latitude},${currentLocation?.longitude}',
                      endLocation,
                      waypoints,
                    );
                  } else {
                    openGoogleMapsNavigation(
                      '${currentLocation?.latitude},${currentLocation?.longitude}',
                      endLocation,
                      [],
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Location data not available.'),
                    ),
                  );
                }
              },
              label: Text('Navigate'),
              icon: Icon(Icons.navigation),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
