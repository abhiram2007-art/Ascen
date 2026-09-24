import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;

  final Connectivity _connectivity = Connectivity();
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isOffline => _isOffline;

  ConnectivityService._internal() {
    _init();
  }

  void _init() {
    _connectivity.checkConnectivity().then(_updateState);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> results) {
    bool isNowOffline = results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (_isOffline != isNowOffline) {
      _isOffline = isNowOffline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
