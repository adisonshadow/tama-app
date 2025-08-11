import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static late SharedPreferences _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Token操作
  static Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }
  
  static Future<String?> getToken() async {
    return _prefs.getString(AppConstants.tokenKey);
  }
  
  static Future<void> clearToken() async {
    await _prefs.remove(AppConstants.tokenKey);
  }
  
  // 视频播放Token操作
  static Future<void> saveVideoToken(String token) async {
    await _prefs.setString(AppConstants.videoTokenKey, token);
  }
  
  static Future<String?> getVideoToken() async {
    return _prefs.getString(AppConstants.videoTokenKey);
  }
  
  static Future<void> clearVideoToken() async {
    await _prefs.remove(AppConstants.videoTokenKey);
  }
  
  // 用户信息操作
  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs.setString(AppConstants.userKey, userJson);
  }
  
  static Future<UserModel?> getUser() async {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJsonSafe(userMap);
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }
  
  static Future<void> clearUser() async {
    await _prefs.remove(AppConstants.userKey);
  }
  
  // 播放过的视频ID操作
  static Future<void> addPlayedVideoId(String videoId) async {
    final playedIds = await getPlayedVideoIds();
    if (!playedIds.contains(videoId)) {
      playedIds.add(videoId);
      // 限制存储的ID数量，避免无限增长
      if (playedIds.length > 1000) {
        playedIds.removeRange(0, playedIds.length - 1000);
      }
      await _prefs.setStringList(AppConstants.playedVideoIdsKey, playedIds);
    }
  }
  
  static Future<List<String>> getPlayedVideoIds() async {
    return _prefs.getStringList(AppConstants.playedVideoIdsKey) ?? [];
  }
  
  static Future<void> clearPlayedVideoIds() async {
    await _prefs.remove(AppConstants.playedVideoIdsKey);
  }
  
  // 清除所有数据
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
