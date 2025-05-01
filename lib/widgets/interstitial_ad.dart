import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-7755526276291947/3087251190',  // Replace with your ad unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          print('Interstitial Ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Failed to load interstitial ad: $error');
        },
      ),
    );
  }

  void showInterstitialAd(BuildContext context, Function onSuccess) {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onSuccess();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          print('Failed to show interstitial ad: $error');
          onSuccess();
        },
      );
    } else {
      print('Interstitial ad is not loaded');
      onSuccess();  // Proceed if ad is not ready
    }
  }
}