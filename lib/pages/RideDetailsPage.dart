/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';

class RideDetailsPage extends StatelessWidget {
  final String rideId;
  final String currentUserId; // Add current user's ID

  RideDetailsPage(this.rideId, this.currentUserId);

  TextEditingController seatsController = TextEditingController();

  Future<void> _showJoinDialog(
    BuildContext context,
    Map<String, dynamic> rideData,
  ) async {
    String pickupStand = '';

    final controller = TextEditingController();
    final places = GoogleMapsPlaces(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');

    // Check if the current user is the creator
    if (currentUserId == rideData['creatorUID']) {
      // Show a message that the creator can't join their own ride
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
                      apiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
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
                        // Ensure non-negative integer input
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
                  onPressed: () {
                    final pickupStand = controller.text;
                    if (seatsController.text.isNotEmpty &&
                        int.parse(seatsController.text) >
                            rideData['selectedSeats']) {
                      // Show an error message if entered seats are greater
                      setState(() {});
                    } else if (pickupStand.isEmpty) {
                      // Show an error message if pickup stand is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a pickup location!'),
                        ),
                      );
                    } else {
                      print(
                        'Joining ride with Pickup Stand: $pickupStand and Seats Required: ${seatsController.text}',
                      );
                      Navigator.of(context).pop();
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
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
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

                    final profileData =
                        profileSnapshot.data!.data() as Map<String, dynamic>;

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
    );
  }
}*/

/*

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import

class RideDetailsPage extends StatelessWidget {
  final String rideId;
  final String currentUserId; // Add current user's ID

  RideDetailsPage(this.rideId, this.currentUserId);

  TextEditingController seatsController = TextEditingController();

  Future<void> _showJoinDialog(
    BuildContext context,
    Map<String, dynamic> rideData,
  ) async {
    String pickupStand = '';

    final controller = TextEditingController();
    final places = GoogleMapsPlaces(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');

    // Check if the current user is the creator
    if (currentUserId == rideData['creatorUID']) {
      // Show a message that the creator can't join their own ride
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
                      apiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
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
                        // Ensure non-negative integer input
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
                      // Show an error message if entered seats are greater
                      setState(() {});
                    } else if (pickupStand.isEmpty) {
                      // Show an error message if pickup stand is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a pickup location!'),
                        ),
                      );
                    } else {
                      // Create a new request document in Firestore
                      await FirebaseFirestore.instance
                          .collection('requests')
                          .doc()
                          .set({
                        'rideId': rideId,
                        'requesterId': currentUserId,
                        'seatsRequested': int.parse(seatsController.text),
                        'status': 'pending',
                      });

                      // Send a notification to the ride creator
                      await sendNotificationToCreator(
                        rideData['creatorUID'],
                        currentUserId,
                        int.parse(seatsController.text),
                        rideId,
                      );

                      Navigator.of(context).pop();
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

  Future<void> sendNotificationToCreator(String creatorUid, String requesterId,
      int seatsRequested, String rideId) async {
    final message = <String, dynamic>{
      'notification': <String, dynamic>{
        'title': 'New ride request received',
        'body':
            '$requesterId has requested $seatsRequested seats in your ride.',
      },
      'data': <String, dynamic>{
        'rideId': rideId,
        'requesterId': requesterId,
        'seatsRequested': seatsRequested.toString(),
      },
      'to':
          '/topics/$creatorUid', // Send to a specific user using their UID as a topic
    };

    try {
      await FirebaseMessaging.instance.send(message);
    } catch (e) {
      print('Error sending FCM message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('rides').doc(rideId).get(),
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

                    final profileData =
                        profileSnapshot.data!.data() as Map<String, dynamic>;

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
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';

class RideDetailsPage extends StatelessWidget {
  final String rideId;
  final String currentUserId; // Add current user's ID

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

    // Check if the current user is the creator
    if (currentUserId == rideData['creatorUID']) {
      // Show a message that the creator can't join their own ride
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
                        // Ensure non-negative integer input
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
                      // Show an error message if entered seats are greater
                      setState(() {});
                    } else if (pickupStand.isEmpty) {
                      // Show an error message if pickup stand is empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a pickup location!'),
                        ),
                      );
                    } else {
                      // Add the ride request to the "riderequest" collection
                      await FirebaseFirestore.instance
                          .collection('riderequest')
                          .add({
                        'rideId': rideId,
                        'requesterName':
                            'User Name', // Replace with actual user name
                        'pickupStand': pickupStand,
                        'seatsRequired': int.parse(seatsController.text),
                        'status':
                            'pending', // You can set an initial status here
                      });

                      print(
                        'Joining ride with Pickup Stand: $pickupStand and Seats Required: ${seatsController.text}',
                      );
                      Navigator.of(context).pop();
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
          // Add the StreamBuilder for displaying ride requests here
        ],
      ),
    );
  }
}
