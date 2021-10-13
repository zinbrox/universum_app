import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-//YOUR ID HERE';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-//YOUR ID HERE';
    }
    else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-//YOUR ID HERE";
    } else if (Platform.isIOS) {
      return "ca-app-pub-//YOUR ID HERE";
    }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-//YOUR ID HERE";
    } else if (Platform.isIOS) {
      return "ca-app-pub-//YOUR ID HERE";
    }
    else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
