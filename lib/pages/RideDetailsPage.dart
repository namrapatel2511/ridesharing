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
    final places = GoogleMapsPlaces(apiKey: 'YOUR_GOOGLE_MAPS_API_KEY');

    // Check if the current user is the creator
    if (currentUserId == rideData['creatorUID']) {
      // Show a message that the creator can't join their own ride
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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
              title: Text('Join Ride'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    PlacesAutocompleteField(
                      apiKey: 'YOUR_GOOGLE_MAPS_API_KEY',
                      controller: controller,
                      inputDecoration:
                          InputDecoration(labelText: 'Pickup Stand'),
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
                      decoration: InputDecoration(labelText: 'Seats Required'),
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
                      Text(
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
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Join'),
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
                        SnackBar(
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
        title: Text('Ride Details'),
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final rideData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Location:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rideData['startLocation'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'End Location:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rideData['endLocation'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Date:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rideData['date'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Time:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rideData['time'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Seats Available:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rideData['selectedSeats'].toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Divider(),
                Text(
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
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final profileData =
                        profileSnapshot.data!.data() as Map<String, dynamic>;

                    return Text(
                      profileData['fullName'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showJoinDialog(context, rideData);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurpleAccent,
                  ),
                  child: Text(
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
