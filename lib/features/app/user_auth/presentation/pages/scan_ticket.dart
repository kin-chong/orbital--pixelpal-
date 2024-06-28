import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'bottom_nav_bar.dart'; // Correct import path

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  String _scannedText = "";
  String? _movieName;
  String? _date;
  String? _ticketPrice;

  Future<void> _getImageAndScan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });

      final inputImage = InputImage.fromFile(imageFile);
      final textDetector = GoogleMlKit.vision.textRecognizer();
      final RecognizedText visionText = await textDetector.processImage(inputImage);

      String scannedText = visionText.text;
      setState(() {
        _scannedText = scannedText;
      });

      _extractTicketDetails(scannedText);
    }
  }

  void _extractTicketDetails(String scannedText) {
    // Example regex patterns, adjust based on your actual ticket format
    RegExp movieNamePattern = RegExp(r"\)\s*(.*)\s*\(", caseSensitive: false);
    RegExp datePattern = RegExp(r"DATE\s*:\s*(\d{2}\s*\w+\s*\d{4})", caseSensitive: false);
    RegExp pricePattern = RegExp(r"PRICE\s*\$\s*([0-9]+\.[0-9]{2})", caseSensitive: false);

    String? movieName = movieNamePattern.firstMatch(scannedText)?.group(1)?.trim();
    String? date = datePattern.firstMatch(scannedText)?.group(1)?.trim();
    String? ticketPrice = pricePattern.firstMatch(scannedText)?.group(1)?.trim();

    setState(() {
      _movieName = movieName;
      _date = date;
      _ticketPrice = ticketPrice;
    });

    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Ticket Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _image != null ? Image.file(_image!) : Container(),
              const SizedBox(height: 10),
              Text('Movie: $_movieName'),
              Text('Date: $_date'),
              Text('Price: \$$_ticketPrice'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save the ticket details
                _saveTicketDetails();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTicketDetails() async {
    if (_movieName != null && _date != null && _ticketPrice != null) {
      CollectionReference tickets = FirebaseFirestore.instance.collection('tickets');
      await tickets.add({
        'movie_name': _movieName,
        'date': _date,
        'ticket_price': _ticketPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Ticket saved: $_movieName, $_date, $_ticketPrice');
      // Show a success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Scan Movie Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _getImageAndScan,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tickets found.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var ticket = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(ticket['movie_name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${ticket['date']}'),
                      Text('Price: \$${ticket['ticket_price']}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Set the current index to the Scan page
        onTap: (index) {
          if (index != 1) {
            // Avoid navigating to the current page
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/front');
                break;
              case 1:
                Navigator.pushNamed(context, '/scan');
                break;
              case 2:
                Navigator.pushNamed(context, '/forum');
                break;
              case 3:
                Navigator.pushNamed(context, '/profile');
                break;
            }
          }
        },
      ),
    );
  }
}
