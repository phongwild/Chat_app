import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/services/SharedPreference/handle_preferences.dart';
import 'package:demo_app/services/chat/chat_service.dart';
import 'package:demo_app/services/fcm/fcm_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

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
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _chatService.downloadImage(imageUrl);
                      },
                      icon: Icon(Icons.download),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close)),
                  ],
                ),
                Image.network(
                  imageUrl, // Hiển thị ảnh lớn
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7fc),
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            // _buildMessageInput()
            _MessageInputWidget(
              receiverUserEmail: widget.receiverUserEmail,
              receiverUserID: widget.receiverUserID,
            )
          ],
        ),
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
    DateTime time = data['timestamp'].toDate();
    String formattedTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    // Kiểm tra xem tin nhắn là ảnh hay không
    bool isImage = data['image'] == true;
    String senderId = data['senderId'];

    // Xác định căn chỉnh
    var alignment = senderId == _auth.currentUser!.uid
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
            child: isImage
                ? GestureDetector(
                    onTap: () {
                      _showImageDialog(context, message);
                    },
                    child: Image.network(
                      message,
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                    ),
                  )
                : Column(
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
}

class _MessageInputWidget extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final ChatService _chatService = ChatService();
  _MessageInputWidget({
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  _MessageInputWidgetState createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<_MessageInputWidget> {
  final TextEditingController _messageCtrl = TextEditingController();
  bool _isAddButtonClicked = false;
  final ImagePicker _picker = ImagePicker(); // Khởi tạo ImagePicker
  XFile? _imageFile;
  final FcmService _fcmService = FcmService();
  // Firebase Storage và Firestore
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _toggleAddButton() {
    setState(() {
      _isAddButtonClicked = !_isAddButtonClicked;
    });
  }
  void _sendMessage() async {
    final String token = await getData('fcm_token');
    if (_messageCtrl.text.isNotEmpty) {
      await widget._chatService
          .sendMessage(widget.receiverUserID, _messageCtrl.text, false);
      _messageCtrl.clear();
      _fcmService.sendNotification(
        title: 'New message from ${_auth.currentUser!.email}',
        body: _messageCtrl.text.toString(),
        token: '$token',
      );
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

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      //Lay ten file anh
      String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      File imageFile = File(_imageFile!.path);
      // Nén ảnh
      Uint8List? compressedImage = await _compressImage(imageFile);
      //Upload anh len firestore
      TaskSnapshot snapshot =
          await _storage.ref('chat_image/$fileName').putData(compressedImage!);

      //Lay Url anh
      String urlImage = await snapshot.ref.getDownloadURL();

      await widget._chatService
          .sendMessage(widget.receiverUserID, urlImage, true);
    } catch (e) {
      print('-----Error uploading image: $e');
    }
  }

  void _selectImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      _uploadImage();
    }
  }

  void _captureImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        _uploadImage();
      } else {
        print("Không có ảnh được chọn");
      }
    } catch (e) {
      print("Lỗi khi chụp ảnh: $e");
    }
  }

  Future<Uint8List?> _compressImage(File image) async {
    // Nén ảnh với chất lượng 80% và giảm kích thước xuống 800px (hoặc bạn có thể điều chỉnh các tham số này)
    var result = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      minWidth: 800,
      minHeight: 800,
      quality: 80, // Chất lượng nén (0 - 100)
      rotate: 0,
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
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
          // Nút chọn ảnh và chụp ảnh
          if (_isAddButtonClicked) ...[
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _captureImage,
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: _selectImage,
            ),
          ],
          // Nút add
          IconButton(
            onPressed: _toggleAddButton,
            icon: Icon(_isAddButtonClicked ? Icons.close : Icons.add),
          ),
          // Dùng TweenAnimationBuilder thay vì AnimatedContainer
          TweenAnimationBuilder(
            tween: Tween<double>(
                begin: _isAddButtonClicked ? 279 : 160,
                end: _isAddButtonClicked ? 160 : 279),
            duration: const Duration(milliseconds: 300),
            builder: (context, double width, child) {
              return Container(
                height: 40,
                width: width,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _messageCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              );
            },
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
