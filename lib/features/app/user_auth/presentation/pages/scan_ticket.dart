import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/chat_overview.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/front_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/no_animation_page_route.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'bottom_nav_bar.dart';
import 'package:logging/logging.dart';
import 'package:pixelpal/services/movie_service.dart';

const String _apiKey =
    'AIzaSyD7G9jtJ5e6BZOYIiyoCaQNWhhVAlV8d-U'; // Replace with your actual API key

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final Logger _logger = Logger('ScanPage');
  File? _image;
  String _scannedText = "";
  TextEditingController _movieNameController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _ticketPriceController = TextEditingController();
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );

    // Set up logging
    Logger.root.level = Level.ALL; // Log all levels
    Logger.root.onRecord.listen((record) {
      // Customize the output format
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (!mounted) return;
      setState(() {
        _image = imageFile;
      });

      // Send the image to Google Gemini API
      final apiResponse = await _sendImageToGemini(imageFile);
      if (!mounted) return;
      if (apiResponse != null) {
        _extractTicketDetails(apiResponse);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to scan the ticket.')),
        );
      }
    } else {
      _logger.warning('No image selected.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<void> _getImageAndScan() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (!mounted) return;
      setState(() {
        _image = imageFile;
      });

      // Send the image to Google Gemini API
      final apiResponse = await _sendImageToGemini(imageFile);
      if (!mounted) return;
      if (apiResponse != null) {
        _extractTicketDetails(apiResponse);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to scan the ticket.')),
        );
      }
    } else {
      _logger.warning('No image selected.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected.')),
      );
    }
  }

  Future<Map<String, dynamic>?> _sendImageToGemini(File image) async {
    try {
      _logger.info('Reading image bytes...');
      final imageBytes = await image.readAsBytes();
      _logger.info('Image bytes length: ${imageBytes.length}');

      final prompt =
          "Tell me what movie name is it, what is the date (in dd MMM yyyy format) and price (omit the leading dollar sign) of the movie ticket, and give me in json. If the movie name is incomplete, complete the name for me.";
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      _logger.info('Sending request to Gemini API...');
      final response = await _model.generateContent(content);
      _logger.info('Response: ${response.text}');

      if (response.text != null) {
        _logger.info('Received response from Gemini API.');
        try {
          final jsonResponse = response.text!
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
          return json.decode(jsonResponse) as Map<String, dynamic>;
        } catch (e) {
          _logger.severe('Error decoding response JSON: $e');
        }
      } else {
        _logger.severe('Gemini API error: No response text.');
      }
    } catch (e) {
      _logger.severe('Error sending image to Gemini API: $e');
    }
    return null;
  }

  void _extractTicketDetails(Map<String, dynamic> apiResponse) {
    String? movieName = apiResponse['movie_name'];
    String? date = apiResponse['date'];
    String? ticketPrice = apiResponse['price'];

    _logger.info(
        'Extracted Details - Movie: $movieName, Date: $date, Price: $ticketPrice');

    if (ticketPrice != null && ticketPrice.toLowerCase() == 'free') {
      ticketPrice = '0 dollars';
    }

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
                    decoration: const InputDecoration(labelText: 'Movie Name'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat("dd MMM yyyy").format(pickedDate);
                        if (!mounted) return;
                        setState(() {
                          _dateController.text = formattedDate;
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: 'Date'),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _ticketPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
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
    final user = FirebaseAuth.instance.currentUser;

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
          _logger.info(
              'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
        }, onError: (e) {
          _logger.severe('Error during upload: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error during upload: $e')),
          );
        });

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        _logger.info('Image URL: $imageUrl');

        // Save the ticket details to Firestore
        CollectionReference tickets =
            FirebaseFirestore.instance.collection('tickets');
        await tickets.add({
          'userId': user!.uid,
          'movie_name': _movieNameController.text,
          'date': _dateController.text,
          'ticket_price': _ticketPriceController.text,
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _logger.info(
            'Ticket saved: ${_movieNameController.text}, ${_dateController.text}, ${_ticketPriceController.text}, $imageUrl');

        // Show a success message or navigate to another screen
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket saved successfully!')),
        );
      } catch (e) {
        _logger.severe('Error saving ticket: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving ticket: $e')),
        );
      }
    } else {
      _logger.warning('Failed to save ticket. Missing details.');
      _logger.info(
          'Image: $_image, Movie: ${_movieNameController.text}, Date: ${_dateController.text}, Price: ${_ticketPriceController.text}');
      if (!mounted) return;
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Scan Movie Ticket'),
        leading: IconButton(
          icon: Icon(Icons.photo_library),
          onPressed: _pickImageFromGallery,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _getImageAndScan,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
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
                return GestureDetector(
                  onTap: () =>
                      _navigateToTicketDetail(context, data, ticket.id),
                  child: GridTile(
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Date: ${data['date'] ?? 'Unknown'}'),
                              Text(
                                  'Price: \$${data['ticket_price'] ?? 'Unknown'}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: FrontPage()),
                );
              case 1:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ScanPage()),
                );
              case 2:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ForumPage()),
                );
              case 3:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ChatOverview()),
                );
              case 4:
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(page: ProfileMenu()),
                );
            }
          }
        },
      ),
    );
  }

  void _navigateToTicketDetail(
      BuildContext context, Map<String, dynamic> ticketData, String ticketId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TicketDetailPage(ticketData: ticketData, ticketId: ticketId),
      ),
    );
  }
}

class TicketDetailPage extends StatefulWidget {
  final Map<String, dynamic> ticketData;
  final String ticketId;

  const TicketDetailPage({required this.ticketData, required this.ticketId});

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final MovieService _movieService = MovieService();
  String? _posterUrl;

  @override
  void initState() {
    super.initState();
    _fetchMoviePoster();
  }

  Future<void> _fetchMoviePoster() async {
    final posterUrl =
        await _movieService.searchMoviePoster(widget.ticketData['movie_name']);
    if (posterUrl != null) {
      setState(() {
        _posterUrl = posterUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ticketData['movie_name'] ?? 'Ticket Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('tickets')
                  .doc(widget.ticketId)
                  .delete();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket deleted successfully.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.ticketData['image_url'] != null)
                Center(
                  child: Image.network(
                    widget.ticketData['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              if (_posterUrl != null)
                Center(
                  child: Image.network(
                    _posterUrl!,
                    fit: BoxFit.cover,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                'Movie: ${widget.ticketData['movie_name'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Date: ${widget.ticketData['date'] ?? 'Unknown'}'),
              const SizedBox(height: 10),
              Text(
                  'Price: \$${widget.ticketData['ticket_price'] ?? 'Unknown'}'),
            ],
          ),
        ),
      ),
    );
  }
}
