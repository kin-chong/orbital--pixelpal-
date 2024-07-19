import 'package:flutter/material.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/bottom_nav_bar.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/forum_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/front_page.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/no_animation_page_route.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/profile_menu.dart';
import 'package:pixelpal/features/app/user_auth/presentation/pages/scan_ticket.dart';

class ChatOverview extends StatefulWidget {
  const ChatOverview({super.key});

  @override
  State<ChatOverview> createState() => _ChatOverviewState();
}

class _ChatOverviewState extends State<ChatOverview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Chats'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
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
}
