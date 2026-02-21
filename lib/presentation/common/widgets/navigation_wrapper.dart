import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_link_app/core/constants/colors.dart';
import 'package:student_link_app/presentation/pulse/screens/feed_screen.dart';
import 'package:student_link_app/presentation/study_room/screens/study_room_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({Key? key}) : super(key: key);

  @override
  _NavigationWrapperState createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),
    const Scaffold(body: Center(child: Text("Connect / Networking"))),
    const Scaffold(body: Center(child: Text("AnonySpace"))),
    const StudyRoomScreen(),
    const Scaffold(body: Center(child: Text("Profile"))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, -5),
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Pulse',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_2),
              label: 'Connect',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.eye_slash),
              label: 'Anonymity',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book),
              label: 'Study',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
