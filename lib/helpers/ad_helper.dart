import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7046141522235121/6928242298';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7046141522235121/6928242298';
    }
    else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7046141522235121/2250646595";
    } else if (Platform.isIOS) {
      return "ca-app-pub-7046141522235121/2250646595";
    }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-7046141522235121/3051704322";
    } else if (Platform.isIOS) {
      return "ca-app-pub-7046141522235121/3051704322";
    }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}