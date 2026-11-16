import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

enum AuthStatus { checking, loggedOut, loggedIn }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.checking;
  AppUser? _user;
  String? _error;
  bool _isGuest = false;
  bool _isActionLoading = false;

  AuthProvider(this._authService, this._tokenStorage);

  AuthStatus get status => _status;
  AppUser? get user => _user;
  String? get error => _error;
  bool get isGuest => _isGuest;
  bool get isActionLoading => _isActionLoading;

  Future<void> init() async {
    _status = AuthStatus.checking;
    _error = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.read();
      if (token == null) {
        _status = AuthStatus.loggedOut;
        _user = null;
        _isGuest = false;
        notifyListeners();
        return;
      }

      _user = await _authService.me(token);
      _status = AuthStatus.loggedIn;
      _isGuest = false;
    } on ApiException catch (e) {
      // Clear invalid token if rejected with 401 Unauthorized
      if (e.statusCode == 401) {
        await _tokenStorage.clear();
      }
      _user = null;
      _status = AuthStatus.loggedOut;
      _isGuest = false;
    } catch (_) {
      _user = null;
      _status = AuthStatus.loggedOut;
      _isGuest = false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _authService.login(email, password);
      await _tokenStorage.save(res.token);
      _user = res.user;
      _status = AuthStatus.loggedIn;
      _isGuest = false;
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isActionLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _authService.register(name, email, password);
      await _tokenStorage.save(res.token);
      _user = res.user;
      _status = AuthStatus.loggedIn;
      _isGuest = false;
      _isActionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _isActionLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _user = null;
    _isGuest = false;
    _status = AuthStatus.loggedOut;
    _error = null;
    notifyListeners();
  }

  void continueAsGuest() {
    _isGuest = true;
    _user = null;
    _status = AuthStatus.loggedOut;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
