import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefUtils {

  static saveStr(String key, List<String> messages) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList(key, messages);
  }

  static readPrefStr(String key) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getStringList(key)?? [];
  }

}
List<String> names = [];