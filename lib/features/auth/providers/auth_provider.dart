import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/video_token_manager.dart';
import '../../../shared/services/auth_state_manager.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<bool>? _authStateSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _loadUserFromStorage();
    _listenToAuthStateChanges();
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
      // 直接清除本地数据，不调用任何API
      _user = null;
      
      // 分别清除需要清除的数据，但保留用户邮箱
      await StorageService.clearToken();
      await StorageService.clearVideoToken();
      await StorageService.clearUser();
      await StorageService.clearPlayedVideoIds();
      
      // 重置认证状态
      AuthStateManager.resetAuthState();
      
      // 用户邮箱会自动保留，因为我们没有调用clearAll()
      print('Local data cleared successfully, email preserved');
      
      // 通知状态变化
      notifyListeners();
    } catch (e) {
      print('Error clearing local data: $e');
      // 即使清除本地数据失败，也要清除内存中的用户状态
      _user = null;
      AuthStateManager.resetAuthState();
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

  /// 监听认证状态变化
  void _listenToAuthStateChanges() {
    _authStateSubscription = AuthStateManager.authStateStream.listen((isExpired) {
      if (isExpired && _user != null) {
        // 认证失效，清除用户状态
        _user = null;
        notifyListeners();
        print('🔐 认证失效，已清除用户状态');
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
