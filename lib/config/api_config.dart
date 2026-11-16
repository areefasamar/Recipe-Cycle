import 'package:flutter/foundation.dart';

/// Base URL for the Recipe Cycle backend API.
/// Editable values: edit here if testing on a physical device (e.g. via adb reverse or LAN IP).
const String _webBaseUrl = 'http://localhost:3000';
const String _androidEmulatorBaseUrl = 'http://10.0.2.2:3000';

class ApiConfig {
  static final String baseUrl = _resolveBaseUrl();

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return _webBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorBaseUrl;
    }
    return _webBaseUrl;
  }
}

final String baseUrl = ApiConfig.baseUrl;
