import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyTextController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  String _recommendation = 'Highly recommend';

  Future<void> _createPost() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': _titleController.text,
        'bodyText': _bodyTextController.text,
        'recommendation': _recommendation,
        'createdAt': Timestamp.now(),
        'userId': user?.uid,
        // Add more fields as needed
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                decoration: InputDecoration(
                  labelText: 'Movie Title',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a movie title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyTextController,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  labelText: 'Body Text',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the body text';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _recommendation,
                dropdownColor: Theme.of(context).colorScheme.primary,
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                decoration: InputDecoration(
                  labelText: 'Recommendation',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                items: <String>[
                  'Highly recommend',
                  'Recommend',
                  'Neutral',
                  'Not recommend',
                  'Very disappointed'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _recommendation = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a recommendation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                child: const Text('Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyTextController.dispose();
    super.dispose();
  }
}
