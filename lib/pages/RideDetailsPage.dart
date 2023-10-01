/*import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';

class RideDetailsPage extends StatelessWidget {
  final String rideId;
  final String currentUserId;

  RideDetailsPage(this.rideId, this.currentUserId);

  TextEditingController seatsController = TextEditingController();

  Future<void> _showJoinDialog(
    BuildContext context,
    Map<String, dynamic> rideData,
  ) async {
    String pickupStand = '';

    final controller = TextEditingController();
    final places =
        GoogleMapsPlaces(apiKey: 'AIzaSyCM8fWUE5pRL0qC4I83fJGebRnP3tdVPpQ');

    if (currentUserId == rideData['creatorUID']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't join your own ride."),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Join Ride'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    PlacesAutocompleteField(
                      apiKey: 'AIzaSyCM8fWUE5pRL0qC4I83fJGebRnP3tdVPpQ',
                      controller: controller,
                      inputDecoration:
                          const InputDecoration(labelText: 'Pickup Stand'),
                      onChanged: (value) async {
                        final predictions = await places.autocomplete(
                          value,
                          language: "en",
                          types: ["address"],
                        );
                      },
                    ),
                    TextField(
                      controller: seatsController,
                      decoration:
                          const InputDecoration(labelText: 'Seats Required'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (int.tryParse(value) != null &&
                            int.parse(value) >= 0) {
                          seatsController.text = value;
                        }
                      },
                    ),
                    if (seatsController.text.isNotEmpty &&
                        int.parse(seatsController.text) >
                            rideData['selectedSeats'])
                      const Text(
                        'Not enough seats available!',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                    child: const Text('Request'),
                    onPressed: () async {
                      final pickupStand = controller.text;

                      if (seatsController.text.isNotEmpty &&
                          int.parse(seatsController.text) >
                              rideData['selectedSeats']) {
                        setState(() {});
                      } else if (pickupStand.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a pickup location!'),
                          ),
                        );
                      } else {
                        final rideRequestDocRef = await FirebaseFirestore
                            .instance
                            .collection('riderequest')
                            .add({
                          'rideId': rideId, // Include rideId in the request
                          'requesterName': 'User Name',
                          'pickupStand': pickupStand,
                          'seatsRequired': int.parse(seatsController.text),
                          'status': 'pending',
                        });

                        final rideCreatorUid = rideData['creatorUID'];
                        final fcmTokenDoc = await FirebaseFirestore.instance
                            .collection('fcmToken')
                            .doc(rideCreatorUid)
                            .get();

                        if (fcmTokenDoc.exists) {
                          final fcmToken = fcmTokenDoc['token'];

                          final messaging = FirebaseMessaging.instance;
                          await messaging.sendMessage(
                            to: fcmToken,
                            data: {
                              'title': 'New Ride Request',
                              'body':
                                  'You have a new ride request from ${'User Name'}!',
                              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                            },
                          );
                        }

                        print(
                            'Joining ride with Pickup Stand: $pickupStand and Seats Required: ${seatsController.text}');
                        Navigator.of(context).pop();
                      }
                    }),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('rides')
                .doc(rideId)
                .get(),
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

              final rideData = snapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                      rideData['startLocation'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'End Location:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['endLocation'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['date'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Time:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['time'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seats Available:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['selectedSeats'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      'Creator Name:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('profiles')
                          .doc(rideData['creatorUID'])
                          .get(),
                      builder: (context, profileSnapshot) {
                        if (profileSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${profileSnapshot.error}'),
                          );
                        }

                        if (!profileSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final profileData = profileSnapshot.data!.data()
                            as Map<String, dynamic>;

                        return Text(
                          profileData['fullName'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () {
                        _showJoinDialog(context, rideData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text(
                        'Join Now',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideDetailsPage extends StatelessWidget {
  final String rideId;
  final String currentUserId;

  RideDetailsPage(this.rideId, this.currentUserId);

  TextEditingController seatsController = TextEditingController();

  Future<void> _showJoinDialog(
    BuildContext context,
    Map<String, dynamic> rideData,
  ) async {
    String pickupStand = '';

    final controller = TextEditingController();
    final places = GoogleMapsPlaces(
        apiKey:
            'AIzaSyCM8fWUE5pRL0qC4I83fJGebRnP3tdVPpQ'); // Replace with your API key

    if (currentUserId == rideData['creatorUID']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't join your own ride."),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Join Ride'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    PlacesAutocompleteField(
                      apiKey:
                          'AIzaSyCM8fWUE5pRL0qC4I83fJGebRnP3tdVPpQ', // Replace with your API key
                      controller: controller,
                      inputDecoration:
                          const InputDecoration(labelText: 'Pickup Stand'),
                      onChanged: (value) async {
                        final predictions = await places.autocomplete(
                          value,
                          language: "en",
                          types: ["address"],
                        );
                      },
                    ),
                    TextField(
                      controller: seatsController,
                      decoration:
                          const InputDecoration(labelText: 'Seats Required'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (int.tryParse(value) != null &&
                            int.parse(value) >= 0) {
                          seatsController.text = value;
                        }
                      },
                    ),
                    if (seatsController.text.isNotEmpty &&
                        int.parse(seatsController.text) >
                            rideData['selectedSeats'])
                      const Text(
                        'Not enough seats available!',
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Request'),
                  onPressed: () async {
                    final pickupStand = controller.text;

                    if (seatsController.text.isNotEmpty &&
                        int.parse(seatsController.text) >
                            rideData['selectedSeats']) {
                      setState(() {});
                    } else if (pickupStand.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a pickup location!'),
                        ),
                      );
                    } else {
                      final rideRequestDocRef = await FirebaseFirestore.instance
                          .collection('riderequest')
                          .add({
                        'rideId': rideId, // Include rideId in the request
                        'requesterId': currentUserId, // Include requester's ID
                        'requesterName': 'User Name',
                        'pickupStand': pickupStand,
                        'seatsRequired': int.parse(seatsController.text),
                        'status': 'pending',
                      });

                      // ...
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('rides')
                .doc(rideId)
                .get(),
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

              final rideData = snapshot.data!.data() as Map<String, dynamic>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                      rideData['startLocation'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'End Location:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['endLocation'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['date'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Time:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['time'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seats Available:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      rideData['selectedSeats'].toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      'Creator Name:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('profiles')
                          .doc(rideData['creatorUID'])
                          .get(),
                      builder: (context, profileSnapshot) {
                        if (profileSnapshot.hasError) {
                          return Center(
                            child: Text('Error: ${profileSnapshot.error}'),
                          );
                        }

                        if (!profileSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final profileData = profileSnapshot.data!.data()
                            as Map<String, dynamic>;

                        return Text(
                          profileData['fullName'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _showJoinDialog(context, rideData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                      child: const Text(
                        'Join Now',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
