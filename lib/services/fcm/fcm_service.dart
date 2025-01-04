import 'package:demo_app/services/SharedPreference/handle_preferences.dart';
import 'package:dio/dio.dart';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';

class FcmService {
  final Dio _dio = Dio();

  FcmService() {
    // Thêm CurlLoggerDioInterceptor vào Dio
    _dio.interceptors.add(CurlLoggerDioInterceptor());
  }

  final String endPoint =
      'https://fcm.googleapis.com/v1/projects/stayserene-f36b5/messages:send';

  Future<void> sendNotification({
    required String title,
    required String body,
    required String token,
  }) async {
    try {
      // Lấy serverKey từ nơi lưu trữ
      final String serverKey = await extractToken();

      // Gửi yêu cầu HTTP bằng Dio
      final response = await _dio.post(
        endPoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverKey',
          },
        ),
        data: {
          "message": {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
          },
        },
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Error sending notification: ${response.data}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
Future<String> extractToken() async {
  // Lấy raw token từ SharedPreferences
  final String rawToken = await getData('token') ?? '';

  // Sử dụng regex để lấy toàn bộ giá trị sau "data="
  final RegExp regex =
      RegExp(r'data=([\w.-]+)'); // Bao gồm cả dấu chấm (.) và gạch ngang (-)
  final Match? match = regex.firstMatch(rawToken);

  if (match != null) {
    final String token = match.group(1)!; // Lấy giá trị thực của token
    if (token.startsWith('ya29')) {
      return token; // Trả về token hợp lệ
    } else {
      throw Exception(
          'Token does not start with "ya29". Invalid token format.');
    }
  } else {
    throw Exception('Invalid token format: Unable to extract token.');
  }
}

