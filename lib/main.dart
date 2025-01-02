import 'dart:convert';

import 'package:demo_app/Screens/ui/splash_screen.dart';
import 'package:demo_app/firebase_options.dart';
import 'package:demo_app/services/auth/auth_service.dart';
import 'package:demo_app/services/notification/notification_service.dart';
import 'package:demo_app/services/permission/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Import package này để đọc tệp

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const serviceAccountPath = 'assets/google_service/account_service.json';
  requestNotificationPermission();
  try {
    // Đọc tệp JSON từ assets
    final jsonString = await rootBundle.loadString(serviceAccountPath);
    final serviceAccount = jsonDecode(jsonString);

    // Sử dụng thông tin từ tệp JSON để tạo credentials
    final credentials = ServiceAccountCredentials.fromJson(serviceAccount);

    // Định nghĩa các scopes cần thiết
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Lấy client với service account
    final client = await clientViaServiceAccount(credentials, scopes);

    //Lấy bearer token từ client
    final authClient = client as AuthClient;
    final token = await authClient.credentials.accessToken;

    print('Token: $token');
    // Đóng client sau khi sử dụng
    client.close();
  } catch (e) {
    print('Error: $e');
  }

  // Khởi tạo Firebase
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo dịch vụ thông báo
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  // Khởi chạy ứng dụng
  runApp(
    Provider(create: (_) => AuthService(), child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: SplashScreen()),
      debugShowCheckedModeBanner: false,
    );
  }
}
