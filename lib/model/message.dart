import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String sendderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool image;

  Message(
      {required this.senderId,
      required this.sendderEmail,
      required this.receiverId,
      required this.message,
      required this.timestamp,
      required this.image});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': sendderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'image': image,
    };
  }
}
