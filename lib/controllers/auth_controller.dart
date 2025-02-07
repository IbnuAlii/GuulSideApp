import 'dart:asy
import 'package:get/get.dart';
import 'package:guul_side/services/auth_service.dart';
import 'package:guul_side/services/network_service.dart';
import 'package:guul_side/models/user.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final _isAuthenticated = false.obs;
  final _token = Rxn<String>();
  final _user = Rxn<User>();
  final _isLoading = false.obs;
  final _isInitialized = false.obs;
  final _hasError = false.obs;
  final _errorMessage = ''.obs;
  Timer? _refreshTimer;

  bool get isAuthenticated => _isAuthenticated.value;
  String? get token => _token.value;
  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    if (_isLoading.value) return;

    _setLoading(true);
    _clearError();

    try {
      await NetworkService.waitForInternet();
      _isAuthenticated.value = await _authService.isSignedIn();
      _token.value = await _authService.getToken();
      if (_isAuthenticated.value) {
        _user.value = await _authService.getCurrentUser();
        _startRefreshTimer();
      }
      print(
          'Authentication check completed. Is authenticated: ${_isAuthenticated.value}');
    } catch (e) {
      _setError(
          'Error during authentication check: ${_getReadableErrorMessage(e)}');
      _isAuthenticated.value = false;
      _token.value = null;
      _user.value = null;
    } finally {
      _setLoading(false);
      _isInitialized.value = true;
    }
  }

  Future<void> signIn(String email, String password) async {
    if (_isLoading.value) return;

    _setLoading(true);
    _clearError();

    try {
      print('Attempting to sign in user: ${email.split('@')[0]}');
      await NetworkService.waitForInternet();
      _token.value = await _authService.signIn(email, password);
      _isAuthenticated.value = true;
      _user.value = await _authService.getCurrentUser();
      _startRefreshTimer();
      print('Sign-in successful for user: ${_user.value?.name}');
    } catch (e) {
      _setError('Sign-in failed: ${_getReadableErrorMessage(e)}');
      _isAuthenticated.value = false;
      _token.value = null;
      _user.value = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    if (_isLoading.value) return;

    _setLoading(true);
    _clearError();

    try {
      print('Attempting to sign up user: $name');
      await NetworkService.waitForInternet();
      await _authService.signUp(name, email, password);
      print('Sign-up successful, attempting to sign in');
      await signIn(email, password);
    } catch (e) {
      _setError('Sign-up failed: ${_getReadableErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  String _getReadableErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    } else if (error is Error) {
      return 'An unexpected error occurred. Please try again.';
    } else {
      return error.toString();
    }
  }

  Future<void> signOut() async {
    if (_isLoading.value) return;

    _setLoading(true);
    _clearError();

    try {
      await NetworkService.waitForInternet();
      await _authService.signOut();
      _isAuthenticated.value = false;
      _token.value = null;
      _user.value = null;
      _stopRefreshTimer();
      print('User signed out successfully');
    } catch (e) {
      _setError('Sign out error: ${_getReadableErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    if (!_isAuthenticated.value || _isLoading.value) return;

    _setLoading(true);
    _clearError();

    try {
      await NetworkService.waitForInternet();
      _user.value = await _authService.getCurrentUser();
      print('User refreshed: ${_user.value?.name}');
    } catch (e) {
      _setError('Refresh user error: ${_getReadableErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getToken() async {
    if (_token.value == null || !_isAuthenticated.value) {
      await checkAuthentication();
    }
    return _token.value;
  }

  Future<String> getValidToken() async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('No token available');
    }

    if (await _authService.isTokenExpired(token)) {
      print('Token expired, refreshing...');
      token = await refreshToken();
      if (token == null) {
        throw Exception('Failed to refresh token');
      }
    }

    return token;
  }

  Future<bool> isSignedIn() async {
    if (!_isAuthenticated.value) {
      await checkAuthentication();
    }
    return _isAuthenticated.value;
  }

  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
    print(message);
  }

  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  void _startRefreshTimer() {
    _stopRefreshTimer();
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 15), (_) => refreshToken());
  }

  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<String?> refreshToken() async {
    try {
      print('Attempting to refresh token');
      final newToken = await _authService.refreshToken();
      _token.value = newToken;
      print('Token refreshed successfully');
      return newToken;
    } catch (e) {
      _setError('Error refreshing token: ${_getReadableErrorMessage(e)}');
      await signOut();
      return null;
    }
  }

  Future<User?> getCurrentUser() async {
    if (_user.value == null || _token.value == null) {
      await checkAuthentication();
    }
    return _user.value;
  }

  @override
  void onClose() {
    _stopRefreshTimer();
    super.onClose();
  }
}
