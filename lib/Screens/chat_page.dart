import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/services/SharedPreference/handle_preferences.dart';
import 'package:demo_app/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final tempStorage = TemporaryStorage();

  void _sendMessage() async {
    if (_messageCtrl.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageCtrl.text);
      _messageCtrl.clear();
    } else {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: Text("Error"),
        description: Text("Message cannot be empty"),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 4),
        foregroundColor: Color(0xff002de3),
        showProgressBar: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7fc),
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput()
        ],
      ),
    );
  }

  // Build the message list
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    // Kiểm tra dữ liệu từ doc
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return Container(
        alignment: Alignment.center,
        child: const Text('No data available'),
      );
    }

    String message = data['message'] ?? 'No message content';
    String timestamp = data['timestamp'] != null
        ? data['timestamp'].toDate().toString()
        : 'No timestamp';
    DateTime time = data['timestamp'].toDate();
    String formattedTime = '${time.hour}:${time.minute}';

    // Xác định căn chỉnh
    var alignment = data['senderId'] == _auth.currentUser!.uid
        ? Alignment.centerRight
        : Alignment.centerLeft;
    var textColor =
        alignment == Alignment.centerRight ? Colors.white : Colors.black;

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: alignment == Alignment.centerRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alignment == Alignment.centerRight
                  ? Color(0xff002DE3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: alignment == Alignment.centerRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
                Text(
                  formattedTime,
                  style: TextStyle(fontSize: 10, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the message input
  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Màu nền chính của widget
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 83.46,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          Container(
            height: 40,
            width: 279,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FC), // Màu nền của TextField
              borderRadius:
                  BorderRadius.circular(8), // Viền bo tròn cho TextField
            ),
            child: TextField(
              controller: _messageCtrl,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none, // Loại bỏ viền mặc định
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Color(0xFF002DE3),
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
