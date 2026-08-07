import 'dart:io';

class ApiClient {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator
  static String get baseUrl {
    return 'https://backend-production-cb05.up.railway.app';
  }

  static String getFullUrl(String path) {
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }
}
