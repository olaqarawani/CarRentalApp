import 'package:flutter/foundation.dart';

const String _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

String get baseUrl {
  if (_configuredBaseUrl.isNotEmpty) {
    return _configuredBaseUrl.replaceAll(RegExp(r'/+$'), '');
  }

  if (kIsWeb) return 'http://localhost:8000';

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => 'http://127.0.0.1:8000',
    _ => 'http://localhost:8000',
  };
}

String get imagesUrl => '$baseUrl/images';
