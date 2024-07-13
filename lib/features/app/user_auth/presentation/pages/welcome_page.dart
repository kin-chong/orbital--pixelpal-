import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Male';
  int _age = 0;
  List<String> _moviePreferences = [];
  String _selectedProfilePicture = 'https://example.com/default_picture.png';
  String _bio = 'Hello! I am using PixelPal.';

  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime', 'Documentary', 'Drama',
    'Family', 'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance',
    'Sci-Fi', 'Thriller', 'War', 'Western'
  ];

  final List<String> _profilePictures = [
    'https://example.com/picture1.png',
    'https://example.com/picture2.png',
    'https://example.com/picture3.png',
    'https://example.com/picture4.png',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('Users').doc(currentUser.uid).update({
        'age': _age,
        'gender': _gender,
        'moviePreferences': _moviePreferences,
        'profilePicture': _selectedProfilePicture,
        'bio': _bio,
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _nextPage() {
    if (_pageController.page!.toInt() == 2) {
      if (_formKey.currentState!.validate()) {
        _saveData();
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _skip() {
    if (_pageController.page!.toInt() == 2) {
      _saveData();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Widget _ageGenderForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Step 1: Age and Gender', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                _age = int.parse(value);
                return null;
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

  Widget _moviePreferencesForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Step 2: Movie Preferences', style: Theme.of(context).textTheme.titleLarge),
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
        key: _formKey,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Step 3: Profile Picture and Bio', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.0,
          runSpacing: 4.0,
          children: _profilePictures.map((pictureUrl) {
            return GestureDetector(
            onTap: () {
              setState(() {
              _selectedProfilePicture = pictureUrl;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
              border: Border.all(
                color: _selectedProfilePicture == pictureUrl ? Colors.yellow : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8.0),
              ),
              child: Image.network(
              pictureUrl,
              width: 50,
              height: 50,
              ),
            ),
            );
          }).toList(),
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
              if (_formKey.currentState!.validate()) {
              _saveData();
              }
            },
            child: const Text('Submit'),
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
