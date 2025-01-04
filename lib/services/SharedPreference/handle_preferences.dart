import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveData(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
  print('Data saved successfully');
}

Future<String> getData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? data = prefs.getString(key);
  if (data != null) {
    return data;
  } else {
    return '';
  }
}

Future<void> removeData(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
  print('Delete $key successfully');
}
