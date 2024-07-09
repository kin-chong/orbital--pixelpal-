import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
  TextEditingController _movieNameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _ticketPriceController = TextEditingController();

  Future<void> _getImageAndScan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });

      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String scannedText = recognizedText.text;
      print('Scanned Text: $scannedText'); // Debug log
      setState(() {
        _scannedText = scannedText;
      });

      _extractTicketDetails(scannedText);
    } else {
      print('No image selected.'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  void _extractTicketDetails(String scannedText) {
    // Example regex patterns, adjust based on your actual ticket format
    RegExp movieNamePattern = RegExp(r"\)\s*(.*)\s*\(", caseSensitive: false);
    RegExp datePattern =
        RegExp(r"DATE\s*:\s*(\d{2}\s*\w+\s*\d{4})", caseSensitive: false);
    RegExp pricePattern =
        RegExp(r"PRICE\s*\$\s*([0-9]+\.[0-9]{2})", caseSensitive: false);

    String? movieName =
        movieNamePattern.firstMatch(scannedText)?.group(1)?.trim();
    String? date = datePattern.firstMatch(scannedText)?.group(1)?.trim();
    String? ticketPrice =
        pricePattern.firstMatch(scannedText)?.group(1)?.trim();

    print(
        'Extracted Details - Movie: $movieName, Date: $date, Price: $ticketPrice'); // Debug log

    setState(() {
      _movieNameController.text = movieName ?? '';
      _dateController.text = date ?? '';
      _ticketPriceController.text = ticketPrice ?? '';
    });

    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Ticket Details'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _image != null ? Image.file(_image!) : Container(),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _movieNameController,
                    decoration: InputDecoration(labelText: 'Movie Name'),
                  ),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                  ),
                  TextFormField(
                    controller: _ticketPriceController,
                    decoration: InputDecoration(labelText: 'Price'),
                  ),
                ],
              ),
            ),
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
    if (_image != null &&
        _movieNameController.text.isNotEmpty &&
        _dateController.text.isNotEmpty &&
        _ticketPriceController.text.isNotEmpty) {
      try {
        // Upload the image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('tickets/$fileName');
        UploadTask uploadTask = storageReference.putFile(_image!);

        // Add error handling for upload task
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          print(
              'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
        }, onError: (e) {
          print('Error during upload: $e'); // Debug log
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error during upload: $e')),
          );
        });

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        print('Image URL: $imageUrl'); // Debug log

        // Save the ticket details to Firestore
        CollectionReference tickets =
            FirebaseFirestore.instance.collection('tickets');
        await tickets.add({
          'movie_name': _movieNameController.text,
          'date': _dateController.text,
          'ticket_price': _ticketPriceController.text,
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print(
            'Ticket saved: ${_movieNameController.text}, ${_dateController.text}, ${_ticketPriceController.text}, $imageUrl'); // Debug log

        // Show a success message or navigate to another screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket saved successfully!')),
        );
      } catch (e) {
        print('Error saving ticket: $e'); // Debug log
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving ticket: $e')),
        );
      }
    } else {
      print('Failed to save ticket. Missing details.');
      print(
          'Image: $_image, Movie: ${_movieNameController.text}, Date: ${_dateController.text}, Price: ${_ticketPriceController.text}'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Failed to save ticket. Missing details.')),
      );
    }
  }

  @override
  void dispose() {
    _movieNameController.dispose();
    _dateController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
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
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var ticket = snapshot.data!.docs[index];
                var data = ticket.data() as Map<String, dynamic>;
                return GridTile(
                  child: Column(
                    children: [
                      Expanded(
                        child: data['image_url'] != null
                            ? Image.network(
                                data['image_url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey,
                                  child:
                                      Center(child: Icon(Icons.broken_image)),
                                ),
                              )
                            : Container(color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['movie_name'] ?? 'Unknown',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Date: ${data['date'] ?? 'Unknown'}'),
                            Text(
                                'Price: \$${data['ticket_price'] ?? 'Unknown'}'),
                          ],
                        ),
                      ),
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
          // Get the current route name
          String? currentRoute = ModalRoute.of(context)?.settings.name;

          // Define target route based on the index
          String targetRoute;
          switch (index) {
            case 0:
              targetRoute = '/front';
              break;
            case 1:
              targetRoute = '/scan';
              break;
            case 2:
              targetRoute = '/forum';
              break;
            case 3:
              targetRoute = '/profile';
              break;
            default:
              return;
          }

          // Navigate to the target route only if it's different from the current route
          if (currentRoute != targetRoute) {
            Navigator.pushReplacementNamed(context, targetRoute);
          }
        },
      ),
    );
  }
}
