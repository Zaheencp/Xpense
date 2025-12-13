import 'package:flutter/material.dart';

class SplashProvider extends ChangeNotifier {
  bool _isSplashDone = false;

  bool get isSplashDone => _isSplashDone;

  void completeSplash() {
    _isSplashDone = true;
    notifyListeners();
  }
}
