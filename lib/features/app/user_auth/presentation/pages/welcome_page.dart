import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pixelpal/global/common/select_image.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  final _ageGenderFormKey = GlobalKey<FormState>();
  final _moviePreferencesFormKey = GlobalKey<FormState>();
  final _profilePictureFormKey = GlobalKey<FormState>();
  String _gender = 'Male';
  int? _age;
  List<String> _moviePreferences = [];
  String? _bio;
  Uint8List? _image;

  final List<String> _availableGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western'
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('Users').doc(currentUser.uid).update({
        'age': _age,
        'gender': _gender,
        'moviePreferences': _moviePreferences,
        'bio': _bio,
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _nextPage() {
    if (_pageController.page!.toInt() == 0) {
      if (_ageGenderFormKey.currentState!.validate()) {
        _ageGenderFormKey.currentState!.save();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } else if (_pageController.page!.toInt() == 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_pageController.page!.toInt() == 2) {
      if (_profilePictureFormKey.currentState!.validate()) {
        _profilePictureFormKey.currentState!.save();
        _saveData();
      }
    }
  }

  void _skip() {
    _nextPage();
  }

  Widget _ageGenderForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Form(
          key: _ageGenderFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Step 1: Age and Gender',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _age = int.parse(value);
                  }
                },
              ),
              const SizedBox(height: 20),
              Text('Gender:', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: const Text('Male'),
                leading: Radio(
                  value: 'Male',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value.toString();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Female'),
                leading: Radio(
                  value: 'Female',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value.toString();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Non-binary'),
                leading: Radio(
                  value: 'Non-binary',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value.toString();
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Prefer not to say'),
                leading: Radio(
                  value: 'Prefer not to say',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value.toString();
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moviePreferencesForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Step 2: Movie Preferences',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              runSpacing: 4.0,
              children: _availableGenres.map((genre) {
                return ChoiceChip(
                  label: Text(genre),
                  selected: _moviePreferences.contains(genre),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _moviePreferences.add(genre);
                      } else {
                        _moviePreferences.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _skip,
                  child: const Text('Skip'),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePictureForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Form(
          key: _profilePictureFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Step 3: Profile Picture and Bio',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              _image != null
                  ? Center(
                      child: ClipOval(
                        child: Image.memory(
                          _image!,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.person,
                        size: 200,
                        color: Colors.grey[800],
                      ),
                    ),
              SizedBox(height: 5),
              TextButton(
                onPressed: () async {
                  Uint8List? img = await selectImage(context, user);
                  if (img != null) {
                    setState(() {
                      _image = img;
                    });
                  }
                },
                child: Text(
                  'Change Picture',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLength: 150,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    _bio = value;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    child: const Text('Back'),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_profilePictureFormKey.currentState!.validate()) {
                        _profilePictureFormKey.currentState!.save();
                        _saveData();
                      }
                    },
                    child: Text(
                      'Submit',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        title: Text(
          'Welcome to PixelPal',
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _ageGenderForm(),
          _moviePreferencesForm(),
          _profilePictureForm(),
        ],
      ),
    );
  }
}
