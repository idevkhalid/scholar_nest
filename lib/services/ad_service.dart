import 'dart:math';
import 'package:applovin_max/applovin_max.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  String _adUnitId = "";
  int _retryAttempt = 0;
  final int _maxExponentialRetryCount = 6;

  // --- COUNTER CONFIGURATION ---
  int _clickCount = 0;
  final int _adFrequency = 3; // Show ad every 3 clicks

  // Initialize
  void initialize(String adUnitId) {
    if (adUnitId.isEmpty) return;
    _adUnitId = adUnitId;

    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        print('✅ [AdService] Ad Loaded & Ready');
        _retryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _retryAttempt++;
        double retryDelay = pow(2, min(_maxExponentialRetryCount, _retryAttempt)).toDouble();
        Future.delayed(Duration(seconds: retryDelay.toInt()), () {
          AppLovinMAX.loadInterstitial(_adUnitId);
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        AppLovinMAX.loadInterstitial(_adUnitId);
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        AppLovinMAX.loadInterstitial(_adUnitId);
      },
    ));

    // Load first ad
    AppLovinMAX.loadInterstitial(_adUnitId);
  }

  // =========================================================
  // CALL THIS METHOD IN YOUR UI
  // =========================================================
  Future<void> showAdWithCounter() async {
    _clickCount++;
    print("👉 [AdService] Click $_clickCount / $_adFrequency");

    // Only trigger logic on 3rd, 6th, 9th... click
    if (_clickCount % _adFrequency == 0) {
      if (_adUnitId.isNotEmpty) {
        await _showInterstitial();
      } else {
        // THIS LOG PROVES IT WORKS WITHOUT THE KEY
        print("⚠️ [AdService] Counter hit 3! Ad would show here (Waiting for Key).");
      }
    }
  }

  Future<void> _showInterstitial() async {
    bool? isReady = await AppLovinMAX.isInterstitialReady(_adUnitId);
    if (isReady == true) {
      AppLovinMAX.showInterstitial(_adUnitId);
    } else {
      print("⚠️ [AdService] Ad not ready yet. Reloading...");
      AppLovinMAX.loadInterstitial(_adUnitId);
    }
  }
}