import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  String _gender = 'Male';
  int _age = 0;
  List<String> _moviePreferences = [];
  final List<String> _availableGenres = [
    'Action', 'Comedy', 'Drama', 'Horror', 'Romance', 'Sci-Fi', 'Thriller'
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _saveData() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('Users').doc(currentUser.uid).set({
        'age': _age,
        'gender': _gender,
        'moviePreferences': _moviePreferences,
      });
      Navigator.pushReplacementNamed(context, '/home');
    }
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  _age = int.parse(value);
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text('Gender:', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
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
              SizedBox(height: 20),
              Text('Movie Preferences:', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
              Wrap(
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveData();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
