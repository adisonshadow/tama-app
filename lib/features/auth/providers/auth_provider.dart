import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/video_token_manager.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _user = await StorageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.login(email, password);
      
      // 添加调试信息
      if (kIsWeb) {
        // debugPrint('🔍 Login API Response: $response');
      }
      
      if (response['status'] == 'SUCCESS') {
        final userData = response['data'];
        
        // 添加调试信息
        if (kIsWeb) {
          // debugPrint('🔍 User Data: $userData');
        }
        
        try {
          _user = UserModel.fromJsonSafe(userData);
          
          // 保存用户信息和token
          await StorageService.saveUser(_user!);
          if (userData['token'] != null) {
            await StorageService.saveToken(userData['token']);
          }
          
          // 获取视频播放token
          try {
            await VideoTokenManager().getVideoToken();
          } catch (e) {
            debugPrint('Failed to fetch video token: $e');
          }
          
          notifyListeners();
          return true;
        } catch (parseError) {
          if (kIsWeb) {
            debugPrint('❌ UserModel.fromJsonSafe failed: $parseError');
            debugPrint('❌ UserData that caused error: $userData');
          }
          _setError('用户数据解析失败：$parseError');
          return false;
        }
      } else {
        _setError(response['message'] ?? '登录失败');
        return false;
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Login API call failed: $e');
      }
      _setError('网络错误：$e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String nickname) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.register(email, password, nickname);
      
      // 添加调试信息
      if (kIsWeb) {
        // debugPrint('🔍 Register API Response: $response');
      }
      
      if (response['status'] == 'SUCCESS') {
        final userData = response['data'];
        
        // 添加调试信息
        if (kIsWeb) {
          debugPrint('🔍 User Data: $userData');
        }
        
        try {
          _user = UserModel.fromJsonSafe(userData);
          
          // 保存用户信息和token
          await StorageService.saveUser(_user!);
          if (userData['token'] != null) {
            await StorageService.saveToken(userData['token']);
          }
          
          // 获取视频播放token
          try {
            await VideoTokenManager().getVideoToken();
          } catch (e) {
            debugPrint('Failed to fetch video token: $e');
          }
          
          notifyListeners();
          return true;
        } catch (parseError) {
          if (kIsWeb) {
            debugPrint('❌ UserModel.fromJsonSafe failed: $parseError');
            debugPrint('❌ UserData that caused error: $userData');
          }
          _setError('用户数据解析失败：$parseError');
          return false;
        }
      } else {
        _setError(response['message'] ?? '注册失败');
        return false;
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Register API call failed: $e');
      }
      _setError('网络错误：$e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (e) {
      print('Logout API call failed: $e');
    } finally {
      // 无论API调用是否成功都清除本地数据
      _user = null;
      await StorageService.clearAll();
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    // 在Chrome中打印错误信息到控制台
    if (kIsWeb) {
      debugPrint('❌ AuthProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
