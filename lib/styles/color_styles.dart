import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? true;
  }

}

class DarkThemeProvider with ChangeNotifier{
  DarkThemePreference darkThemePreference =  DarkThemePreference();
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value){
    _darkTheme = value;
    darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }
}
class FontPreference {
  static const THEME_STATUS = "fontName";

  setFont(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(THEME_STATUS, value);
  }

  Future<String> getTheme() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(THEME_STATUS) ?? "Default";
  }

}

class FontProvider with ChangeNotifier{
  FontPreference fontPreference =  FontPreference();
  String _fontName = "Default";

  String get fontName => _fontName;

  set fontName(String value){
    _fontName = value;
    fontPreference.setFont(value);
    notifyListeners();
  }
}

class Styles {
  static ThemeData themeData(bool isDarkTheme, String fontName, BuildContext context) {
    return ThemeData(
      /*
      textTheme: GoogleFonts.oswaldTextTheme(
        Theme.of(context).textTheme),
       */
      //fontFamily: GoogleFonts.rubik().fontFamily,
      fontFamily: fontName=="Default"? GoogleFonts.rubik().fontFamily : fontName=="Retro NASA"? "Nasalization" : fontName=="Alien"? "Alien"
          : fontName=="Comfortaa"? GoogleFonts.comfortaa().fontFamily : GoogleFonts.montserrat().fontFamily,




      primarySwatch: Colors.orange,
      primaryColor: isDarkTheme ? Colors.black : Colors.white,

      backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),

      indicatorColor: Colors.orange,
      //indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),
      hintColor: isDarkTheme ? Colors.white : Colors.black,

      highlightColor: isDarkTheme ? Color(0xff372901) : Color(0xffFCE192),
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),


      focusColor: isDarkTheme ? Color(0xff0B2512) : Colors.purple,
      disabledColor: Colors.grey,
      textSelectionColor: isDarkTheme ? Colors.white : Colors.black,
      cardColor: isDarkTheme ? Colors.grey[900] : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      shadowColor: isDarkTheme? Colors.white38 : Colors.black12,

      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          buttonColor: isDarkTheme ? Colors.black12 : Colors.black,
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),


      toggleButtonsTheme: Theme.of(context).toggleButtonsTheme.copyWith(
          color: Colors.orange,
        selectedColor: Colors.orange,
      ),



      appBarTheme: AppBarTheme(
        elevation: 0.0,
      ),
    );

  }
}