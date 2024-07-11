import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/front_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';
import 'package:pixelpal/global/common/toast.dart';
import 'bottom_nav_bar.dart'; // Correct import path
import 'no_animation_page_route.dart'; // Correct import path
import 'package:intl/intl.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  // Method to get the appropriate emoji based on recommendation level
  String getRecommendationEmoji(String recommendation) {
    switch (recommendation) {
      case 'Highly recommend':
        return '😊'; // Smiling face with smiling eyes
      case 'Recommend':
        return '🙂'; // Slightly smiling face
      case 'Neutral':
        return '😐'; // Neutral face
      case 'Don\'t recommend':
        return '🙁'; // Slightly frowning face
      case 'Very disappointed':
        return '😞'; // Disappointed face
      default:
        return '😐'; // Neutral face for undefined values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Forum',
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.tertiary),
            onPressed: () {
              Navigator.pushNamed(context, '/createPost');
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: (context, index) {
                var post = snapshot.data!.docs[index];
                String recommendationEmoji =
                    getRecommendationEmoji(post['recommendation']);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text(
                          recommendationEmoji,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Text(
                        post['title'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          NoAnimationPageRoute(
                            page: ForumDetailPage(postId: post.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            // Avoid navigating to the current page
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
                  NoAnimationPageRoute(page: ProfileMenu()),
                );
            }
          }
        },
      ),
    );
  }
}

class ForumDetailPage extends StatefulWidget {
  final String postId;

  const ForumDetailPage({super.key, required this.postId});

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String? username;

  Future<String?> _getUsername(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['username'];
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
    return null;
  }

  Future<void> _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('comments').add({
        'postId': widget.postId,
        'userId': user?.uid, // Replace with actual user ID
        'text': _commentController.text,
        'createdAt': Timestamp.now(),
      });

      _commentController.clear();
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    var dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      showToast(message: "Error deleting comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Forum Post Details',
          style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Post not found',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            );
          } else {
            var post = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        post['bodyText'],
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Comments:',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('postId', isEqualTo: widget.postId)
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data?.docs.length ?? 0,
                          itemBuilder: (context, index) {
                            var comment = snapshot.data!.docs[index];
                            var createdAt = comment['createdAt'] as Timestamp;
                            var formattedTime = formatTimestamp(createdAt);
                            var commentUserId = comment['userId'];

                            return FutureBuilder(
                              future: _getUsername(commentUserId),
                              builder: (context, usernameSnapshot) {
                                if (usernameSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (usernameSnapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${usernameSnapshot.error}',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                    ),
                                  );
                                } else {
                                  username =
                                      usernameSnapshot.data ?? 'Anonymous';

                                  Widget commentTile = Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius:
                                              22, // Increased radius for bigger avatar
                                          child: Icon(
                                            FontAwesomeIcons.user,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                            size:
                                                20, // Increased size of the icon
                                          ),
                                        ),
                                        const SizedBox(
                                            width:
                                                12), // Increased spacing for better alignment
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      username!,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .tertiary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    formattedTime,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height:
                                                      2), // Decreased spacing
                                              Text(
                                                comment['text'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (commentUserId == user?.uid) {
                                    commentTile = Dismissible(
                                      key: Key(comment.id),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (direction) {
                                        _deleteComment(comment.id);
                                      },
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        color: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Icon(Icons.delete,
                                            color: Colors.white),
                                      ),
                                      child: commentTile,
                                    );
                                  }
                                  return commentTile;
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send,
                            color: Theme.of(context).colorScheme.tertiary),
                        onPressed: _addComment,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      /* bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/scan');
              break;
            case 2:
              // Stay on the current page
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ), */
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
