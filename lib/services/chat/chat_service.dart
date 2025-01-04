import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/model/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Send
  Future<void> sendMessage(
      String receiverUserID, String message, bool image) async {
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
      image: image,
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

  Future<void> downloadImage(String imageUrl) async {
    try {
      // Tạo thư mục lưu ảnh
      final directory = await getExternalStorageDirectory();
      final fileName = imageUrl.split('/').last; // Lấy tên file từ URL
      final savePath = '${directory!.path}/$fileName';

      // Xóa file cũ nếu có
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Tải ảnh về từ đầu
      final taskId = await FlutterDownloader.enqueue(
        url: imageUrl,
        savedDir: directory.path,
        fileName: fileName,
        showNotification: true, // Hiển thị thông báo khi tải xong
        openFileFromNotification: true, // Mở file khi tải xong
      );

      print("Download task ID: $taskId");
    } catch (e) {
      print("Error downloading image: $e");
    }
  }
}
