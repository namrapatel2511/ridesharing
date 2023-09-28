/*import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Cloud Messaging

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController fullNameController = TextEditingController();
  String? selectedGender;
  TextEditingController numberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  XFile? _imageFile;
  final _formKey = GlobalKey<FormState>();

  String? savedFullName;
  String? savedGender;
  String? savedNumber;
  String? savedAge;
  String? savedImageURL;

  String editedFullName = '';
  String editedNumber = '';
  String editedAge = '';

  bool isEditMode = false;

  set enteredImagePath(String enteredImagePath) {}

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          savedFullName = profileSnapshot['fullName'];
          savedGender = profileSnapshot['gender'];
          savedNumber = profileSnapshot['number'];
          savedAge = profileSnapshot['age'];
          savedImageURL = profileSnapshot['image'];

          editedFullName = savedFullName ?? '';
          editedNumber = savedNumber ?? '';
          editedAge = savedAge ?? '';

          fullNameController.text = editedFullName;
          selectedGender = savedGender;
          numberController.text = editedNumber;
          ageController.text = editedAge;
        });
      }
    }
  }

  Future<void> _completeProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String imageDownloadUrl = savedImageURL ?? '';

      if (_imageFile != null) {
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await storageReference.putFile(File(_imageFile!.path));

        imageDownloadUrl = await storageReference.getDownloadURL();

        enteredImagePath = _imageFile!.path;
      }

      Map<String, dynamic> updatedFields = {
        if (fullNameController.text.isNotEmpty)
          'fullName': fullNameController.text,
        'gender': selectedGender,
        if (numberController.text.isNotEmpty) 'number': numberController.text,
        if (ageController.text.isNotEmpty) 'age': ageController.text,
        'image': imageDownloadUrl,
      };

      try {
        final profileRef =
            FirebaseFirestore.instance.collection('profiles').doc(user.uid);

        // Check if the document exists
        final profileSnapshot = await profileRef.get();

        if (profileSnapshot.exists) {
          await profileRef.update(updatedFields);
        } else {
          // If the document doesn't exist, create it
          await profileRef.set(updatedFields);
        }

        // Store the FCM token in Firestore
        String? fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await profileRef.set({'fcmToken': fcmToken}, SetOptions(merge: true));
        }

        setState(() {
          isEditMode = false;
        });

        await loadUserProfile();

        // Show the completion message
        _showCompletionMessage();
      } catch (e) {
        // Handle Firestore errors
        print('Error updating profile: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedImage;
    });
  }

  Future<void> _showCompletionMessage() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Completed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your profile has been updated.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_imageFile == null) {
                      _pickImage();
                    }
                  },
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                            as ImageProvider<Object>?
                        : savedImageURL != null
                            ? NetworkImage(savedImageURL!)
                                as ImageProvider<Object>?
                            : null,
                    child: _imageFile == null && savedImageURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                onChanged: (value) {
                  editedFullName = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              Column(
                children: [
                  ListTile(
                    title: const Text("Male"),
                    leading: Radio(
                      value: "Male",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Female"),
                    leading: Radio(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Other"),
                    leading: Radio(
                      value: "Other",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                onChanged: (value) {
                  editedNumber = value;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                onChanged: (value) {
                  editedAge = value;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _completeProfile();
                  }
                },
                child: const Text("Complete Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
/*
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController fullNameController = TextEditingController();
  String? selectedGender;
  TextEditingController numberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  XFile? _imageFile;
  final _formKey = GlobalKey<FormState>();

  String? savedFullName;
  String? savedGender;
  String? savedNumber;
  String? savedAge;
  String? savedImageURL;

  String editedFullName = '';
  String editedNumber = '';
  String editedAge = '';

  bool isEditMode = false;

  set enteredImagePath(String enteredImagePath) {}

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          savedFullName = profileSnapshot['fullName'];
          savedGender = profileSnapshot['gender'];
          savedNumber = profileSnapshot['number'];
          savedAge = profileSnapshot['age'];
          savedImageURL = profileSnapshot['image'];

          editedFullName = savedFullName ?? '';
          editedNumber = savedNumber ?? '';
          editedAge = savedAge ?? '';

          fullNameController.text = editedFullName;
          selectedGender = savedGender;
          numberController.text = editedNumber;
          ageController.text = editedAge;
        });
      }
    }
  }

  Future<void> _completeProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String imageDownloadUrl = savedImageURL ?? '';

      if (_imageFile != null) {
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await storageReference.putFile(File(_imageFile!.path));

        imageDownloadUrl = await storageReference.getDownloadURL();

        enteredImagePath = _imageFile!.path;
      }

      Map<String, dynamic> updatedFields = {
        if (fullNameController.text.isNotEmpty)
          'fullName': fullNameController.text,
        'gender': selectedGender,
        if (numberController.text.isNotEmpty) 'number': numberController.text,
        if (ageController.text.isNotEmpty) 'age': ageController.text,
        'image': imageDownloadUrl,
      };

      try {
        final profileRef =
            FirebaseFirestore.instance.collection('profiles').doc(user.uid);

        // Check if the document exists
        final profileSnapshot = await profileRef.get();

        if (profileSnapshot.exists) {
          await profileRef.update(updatedFields);
        } else {
          // If the document doesn't exist, create it
          await profileRef.set(updatedFields);
        }

        setState(() {
          isEditMode = false;
        });

        await loadUserProfile();

        // Show the completion message
        _showCompletionMessage();
      } catch (e) {
        // Handle Firestore errors
        print('Error updating profile: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedImage;
    });
  }

  Future<void> _showCompletionMessage() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Completed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your profile has been updated.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_imageFile == null) {
                      _pickImage();
                    }
                  },
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                            as ImageProvider<Object>?
                        : savedImageURL != null
                            ? NetworkImage(savedImageURL!)
                                as ImageProvider<Object>?
                            : null,
                    child: _imageFile == null && savedImageURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                onChanged: (value) {
                  editedFullName = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              Column(
                children: [
                  ListTile(
                    title: const Text("Male"),
                    leading: Radio(
                      value: "Male",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Female"),
                    leading: Radio(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Other"),
                    leading: Radio(
                      value: "Other",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                onChanged: (value) {
                  editedNumber = value;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your mobile number.';
                  } else if (value.length != 10) {
                    return 'Mobile number should be 10 digits.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                onChanged: (value) {
                  editedAge = value;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your age.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _completeProfile();
                  }
                },
                child: const Text("Complete Profile"),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  TextEditingController fullNameController = TextEditingController();
  String? selectedGender;
  TextEditingController numberController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  XFile? _imageFile;
  final _formKey = GlobalKey<FormState>();

  String? savedFullName;
  String? savedGender;
  String? savedNumber;
  String? savedAge;
  String? savedImageURL;

  String editedFullName = '';
  String editedNumber = '';
  String editedAge = '';

  bool isEditMode = false;

  set enteredImagePath(String enteredImagePath) {}

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          savedFullName = profileSnapshot['fullName'];
          savedGender = profileSnapshot['gender'];
          savedNumber = profileSnapshot['number'];
          savedAge = profileSnapshot['age'];
          savedImageURL = profileSnapshot['image'];

          editedFullName = savedFullName ?? '';
          editedNumber = savedNumber ?? '';
          editedAge = savedAge ?? '';

          fullNameController.text = editedFullName;
          selectedGender = savedGender;
          numberController.text = editedNumber;
          ageController.text = editedAge;
        });
      }
    }
  }

  Future<void> _completeProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String imageDownloadUrl = savedImageURL ?? '';

      if (_imageFile != null) {
        firebase_storage.Reference storageReference = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await storageReference.putFile(File(_imageFile!.path));

        imageDownloadUrl = await storageReference.getDownloadURL();

        enteredImagePath = _imageFile!.path;
      }

      Map<String, dynamic> updatedFields = {
        if (fullNameController.text.isNotEmpty)
          'fullName': fullNameController.text,
        'gender': selectedGender,
        if (numberController.text.isNotEmpty) 'number': numberController.text,
        if (ageController.text.isNotEmpty) 'age': ageController.text,
        'image': imageDownloadUrl,
      };

      try {
        final profileRef =
            FirebaseFirestore.instance.collection('profiles').doc(user.uid);

        final profileSnapshot = await profileRef.get();

        if (profileSnapshot.exists) {
          await profileRef.update(updatedFields);
        } else {
          await profileRef.set(updatedFields);
        }

        final fcmTokenDoc =
            FirebaseFirestore.instance.collection('fcmToken').doc(user.uid);
        final fcmTokenData = await fcmTokenDoc.get();

        if (!fcmTokenData.exists) {
          final String? newToken = await _firebaseMessaging.getToken();
          print("Newly Generated Token: $newToken");

          if (newToken != null) {
            await fcmTokenDoc.set({'token': newToken});
          }
        }

        setState(() {
          isEditMode = false;
        });

        await loadUserProfile();

        _showCompletionMessage();
      } catch (e) {
        print('Error updating profile: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedImage;
    });
  }

  Future<void> _showCompletionMessage() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Completed'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your profile has been updated.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_imageFile == null) {
                      _pickImage();
                    }
                  },
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                            as ImageProvider<Object>?
                        : savedImageURL != null
                            ? NetworkImage(savedImageURL!)
                                as ImageProvider<Object>?
                            : null,
                    child: _imageFile == null && savedImageURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                onChanged: (value) {
                  editedFullName = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              Column(
                children: [
                  ListTile(
                    title: const Text("Male"),
                    leading: Radio(
                      value: "Male",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Female"),
                    leading: Radio(
                      value: "Female",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text("Other"),
                    leading: Radio(
                      value: "Other",
                      groupValue: selectedGender,
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                onChanged: (value) {
                  editedNumber = value;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your mobile number.';
                  } else if (value.length != 10) {
                    return 'Mobile number should be 10 digits.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                onChanged: (value) {
                  editedAge = value;
                },
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your age.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _completeProfile();
                  }
                },
                child: const Text("Complete Profile"),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
