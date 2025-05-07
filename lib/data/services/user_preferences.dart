import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/artisan_model.dart';

class UserPreferences {
  static const String _artisanKey = 'logged_in_artisan';

  static Future<void> saveArtisan(Artisan artisan) async {
    try{
      final prefs = await SharedPreferences.getInstance();
      final artisanJson = jsonEncode(artisan.toJson());
      await prefs.setString(_artisanKey, artisanJson);
    }catch(e)
    {
      return null;
    }


  }

  static Future<Artisan?> getArtisan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final artisanJson = prefs.getString(_artisanKey);
      if (artisanJson != null) {
        final artisanMap = jsonDecode(artisanJson) as Map<String, dynamic>;
        return Artisan.fromJson(artisanMap);

      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearArtisan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_artisanKey);
  }
}
