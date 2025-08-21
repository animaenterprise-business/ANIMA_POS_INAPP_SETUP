import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String currency;
  final String theme; // 'light' or 'dark'
  AppConfig({required this.supabaseUrl, required this.supabaseAnonKey, this.currency='BDT', this.theme='light'});
}

class ConfigService {
  static const _storage = FlutterSecureStorage();
  static const _kUrl = 'cfg_supabase_url';
  static const _kKey = 'cfg_supabase_anon';
  static const _kCur = 'cfg_currency';
  static const _kTheme = 'cfg_theme';

  static Future<AppConfig?> read() async {
    final url = await _storage.read(key: _kUrl);
    final key = await _storage.read(key: _kKey);
    if (url == null || key == null) return null;
    final cur = await _storage.read(key: _kCur) ?? 'BDT';
    final theme = await _storage.read(key: _kTheme) ?? 'light';
    return AppConfig(supabaseUrl: url, supabaseAnonKey: key, currency: cur, theme: theme);
  }

  static Future<void> save(AppConfig c) async {
    await _storage.write(key: _kUrl, value: c.supabaseUrl);
    await _storage.write(key: _kKey, value: c.supabaseAnonKey);
    await _storage.write(key: _kCur, value: c.currency);
    await _storage.write(key: _kTheme, value: c.theme);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
