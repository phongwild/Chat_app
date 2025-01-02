import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/model/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Send
  Future<void> sendMessage(String receiverUserID, String message) async {
    // get current user
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create new message
    Message newMess = Message(
      senderId: currentUserId,
      sendderEmail: currentUserEmail,
      receiverId: receiverUserID,
      message: message,
      timestamp: timestamp,
      imageUrl: '',
    );

    // construct chat room id from current user id and receiver user id
    List<String> ids = [currentUserId, receiverUserID];
    ids.sort();
    String chatRoomId = ids.join('_');

    // add message to db
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMess.toMap());
  }

  //Get
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
    
  }
}
