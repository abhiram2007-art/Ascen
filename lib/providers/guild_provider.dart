import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/guild_model.dart';
import '../services/guild_service.dart';

class GuildProvider extends ChangeNotifier {
  final GuildService _guildService = GuildService();
  
  GuildModel? _currentGuild;
  StreamSubscription<GuildModel?>? _guildSubscription;
  bool _isLoading = false;

  GuildModel? get currentGuild => _currentGuild;
  bool get isLoading => _isLoading;

  void init(String? guildId) {
    _guildSubscription?.cancel();
    if (guildId == null) {
      _currentGuild = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _guildSubscription = _guildService.getGuild(guildId).listen((guild) {
      _currentGuild = guild;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createGuild(String name, String description, String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _guildService.createGuild(name, description, userId);
      // The user document will update via Auth/Player provider, which should then call init() again with new guildId
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGuild(String guildId, String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _guildService.joinGuild(guildId, userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveGuild(String userId) async {
    if (_currentGuild == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final isLeader = _currentGuild!.leaderId == userId;
      await _guildService.leaveGuild(_currentGuild!.id, userId, isLeader);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _guildSubscription?.cancel();
    super.dispose();
  }
}
