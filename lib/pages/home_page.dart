/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'create_ride.dart';
import 'browse_rides.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _navigateToCreateRidePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  void _navigateToBrowseRidesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowseRidesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carpool App"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToProfilePage(context),
              child: Text("View Profile"),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToCreateRidePage(context),
              child: Text("Create Ride"),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToBrowseRidesPage(context),
              child: Text("Join Ride"),
            ),
          ],
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'create_ride.dart';
import 'browse_rides.dart';
import 'created_ride_details.dart';
import 'joined_ride_details.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _navigateToProfilePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void _navigateToCreateRidePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Home(),
      ),
    );
  }

  void _navigateToBrowseRidesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowseRidesPage(),
      ),
    );
  }

  void _navigateToCreatedRideDetailsPage(BuildContext context) {
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriverRideDetailsPage(user!.uid),
        ),
      );
    }
  }

/*
  void _navigateToJoinedRideDetailsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JoinedRideDetailsPage(), // Replace with your JoinedRideDetailsPage
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Carpool App"),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _navigateToProfilePage(context),
              child: Text("View Profile"),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToCreateRidePage(context),
              child: Text("Create Ride"),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToBrowseRidesPage(context),
              child: Text("Join Ride"),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToCreatedRideDetailsPage(context),
              child: Text("Created Ride Details"),
            ), /*
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _navigateToJoinedRideDetailsPage(
                  context), // Added button for Joined Ride Details
              child: Text("Joined Ride Details"),
            ),*/
          ],
        ),
      ),
    );
  }
}
