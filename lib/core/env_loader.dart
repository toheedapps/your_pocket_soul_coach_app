import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class EnvLoader {
  static Map<String, dynamic>? _env;

  static Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/config/env.json');
    _env = jsonDecode(jsonString);
  }

  static String get(String key) {
    if (_env == null) {
      throw Exception("Environment not loaded. Call EnvLoader.load() first.");
    }
    return _env![key];
  }
}
