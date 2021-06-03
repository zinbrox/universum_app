import 'package:flutter/material.dart';
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
//List<String> names = [];


class LaunchNames {
  static const name = "launchNames";

  setNames(List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(name, value);
  }

  Future<List<String>> getNames() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(name)?? [];
  }

}

class LaunchNamesProvider with ChangeNotifier{
  LaunchNames launchNamePreference =  LaunchNames();
  List<String> _launchNames = [];

  List<String> get launchName => _launchNames;

  set launchName(List<String> value){
    _launchNames = value;
    launchNamePreference.setNames(value);
    notifyListeners();
  }
}



