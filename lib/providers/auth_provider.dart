import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _user = FirebaseAuth.instance.currentUser;
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      UserCredential userCredential = await _authService.signUp(email, password);

      if (userCredential.user != null) {
        final newUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          level: 1,
          xp: 0,
          totalXP: 0,
          rank: 'E',
          streak: 0,
          bestStreak: 0,
          title: 'Newborn Player',
          shadowArmy: 0,
          createdAt: DateTime.now(),
          stats: const {'strength': 0, 'agility': 0, 'intelligence': 0, 'vitality': 0, 'perception': 0},
          preferences: const {'notifications': true, 'dark_mode': true},
        );

        await _firestoreService.createUserProfile(
          userCredential.user!.uid,
          newUser.toMap(), // Assuming UserModel has a toMap method
        );

        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_getFriendlyErrorMessage(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      clearError();

      await _authService.signIn(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getFriendlyErrorMessage(e));
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      clearError();
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      _setError(_getFriendlyErrorMessage(e));
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
