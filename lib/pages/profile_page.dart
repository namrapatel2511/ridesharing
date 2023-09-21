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

  void _completeProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String imageDownloadUrl = '';

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

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .update(updatedFields);

      setState(() {
        isEditMode = false;
      });
      await loadUserProfile();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    XFile? pickedImage = await _imagePicker.pickImage(source: source);
    setState(() {
      _imageFile = pickedImage;
    });
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Select Image Source"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera),
                                title: const Text("Take Picture"),
                                onTap: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.image),
                                title: const Text("Pick from Gallery"),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: savedImageURL != null
                        ? NetworkImage(savedImageURL!)
                        : null,
                    child:
                        savedImageURL == null ? const Icon(Icons.person) : null,
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
