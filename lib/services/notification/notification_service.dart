import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Lấy FCM Token
  Future<String> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token ?? '';
    } catch (e) {
      print('Error fetching FCM Token: $e');
      return '';
    }
  }

  /// Xử lý thông báo nền
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message received: ${message.notification?.title}');
  }

  /// Khởi tạo dịch vụ thông báo
  Future<void> initialize() async {
    // Cài đặt thông báo cục bộ
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Tạo kênh thông báo (chỉ trên Android)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mess_01', // ID kênh
      'Notification Mess', // Tên kênh
      description: 'This channel is used for messaging notifications.',
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Đăng ký xử lý thông báo
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}, ${message.notification?.body}');
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  /// Hiển thị thông báo cục bộ
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        await _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? 'No Title',
          notification.body ?? 'No Body',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'mess_01', // ID kênh
              'Notification Mess', // Tên kênh
              channelDescription: 'This channel is used for messaging notifications.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      } else {
        print('Notification or Android details are null.');
      }
    } catch (e) {
      print('Error displaying notification: $e');
    }
  }
}
