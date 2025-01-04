import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:demo_app/Screens/ui/bottom_nav/home_page.dart';

class BottomNav extends StatelessWidget {
  final User? user;
  const BottomNav({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    int _selected = 0;
    const List<Widget> _widgetOption = <Widget>[
      HomePage(),
      Center(child: Text('data')),
      Center(child: Text('More'))
    ];
    void onItemClicked(int index) {
      _selected = index;
    }
    return Scaffold(
      body: SafeArea(child: _widgetOption.elementAt(_selected)),
      bottomNavigationBar: Container(
        child: BottomNavigationBar(items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Icon(Icons.home),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.transparent,
            icon: Icon(Icons.more_horiz),
            label: 'More',
          )
        ],
          currentIndex: _selected,
          onTap: onItemClicked,
        ),
      ),
    );
  }
}
