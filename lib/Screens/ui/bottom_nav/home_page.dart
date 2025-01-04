import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/Screens/chat_page.dart';
import 'package:demo_app/services/SharedPreference/handle_preferences.dart';
import 'package:demo_app/services/notification/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    _setUpNotification();
    super.initState();
  }
  _setUpNotification() async {
    var token = await NotificationService().getFCMToken();
    saveData('fcm_token', '$token');
    print(token);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Contacts',
            style: TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Color(0xffADB5BD)),
                  prefixIcon: Icon(Icons.search, color: Color(0xffADB5BD)),
                  filled: true, // Cho phép sử dụng fillColor
                  fillColor: Color(0xFFF7F7FC), // Màu nền
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      color: Color(0xFFF7F7FC), // Màu viền
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      color: Color(0xFFF7F7FC), // Màu viền khi không focus
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(
                      color: Color(0xFFF7F7FC), // Màu viền khi focus
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildUserList()),
          ],
        ));
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        snapshot.data!.docs.forEach((doc) {
          final data = doc.data()
              as Map<String, dynamic>; // Chuyển đổi DocumentSnapshot thành Map
          final currentUser = _auth.currentUser!.email;
          if (data['email'] == currentUser) {
            print('Email trùng khớp: ${data['email']}');
          }
        });

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email != data['email']) {
      return GestureDetector(
        onTap: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(receiverUserEmail: data['email'], receiverUserID: data['uid'])))
        },
        child: Container(
          height: 90,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 75,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xffEDEDED),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.account_circle, size: 45),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      data['email'],
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Online',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xffADB5BD),
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
