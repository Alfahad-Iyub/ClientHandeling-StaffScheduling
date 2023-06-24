import 'package:chatter/screens/allChatPage.dart';
import 'package:chatter/screens/assignedChatPage.dart';
import 'package:chatter/screens/completedChatPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      allChatPage(username: widget.username),
      assignedChatPage(username: widget.username),
      completedChatPage(username: widget.username),
    ];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: currentIndex,
      children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          //showUnselectedLabels: false,
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'All',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Assigned',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'My Completed',
            ),
          ],
        ),
      );
}
