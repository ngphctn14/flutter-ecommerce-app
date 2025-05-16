import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _key = 'guest_session_id';

  /// Gọi hàm này khi mở app/web lần đầu (main function hoặc initState)
  static Future<String> getOrCreateSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString(_key);

    if (sessionId == null) {
      // Tạo sessionId ngẫu nhiên
      sessionId = _generateSessionId();
      await prefs.setString(_key, sessionId);
    }

    return sessionId;
  }

  static String _generateSessionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(32, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
