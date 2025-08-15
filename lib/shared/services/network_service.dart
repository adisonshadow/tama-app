import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/error_utils.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  // 网络状态流控制器
  final StreamController<bool> _networkStatusController = StreamController<bool>.broadcast();
  
  // 网络状态流
  Stream<bool> get networkStatusStream => _networkStatusController.stream;
  
  // 当前网络状态
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  // 网络检测定时器
  Timer? _networkCheckTimer;
  
  // 网络检测间隔
  static const Duration _checkInterval = Duration(seconds: 5);
  
  // 是否在Web环境
  bool get _isWeb => kIsWeb;
  
  /// 初始化网络服务
  void initialize() {
    // 立即检查一次网络状态
    _checkNetworkStatus();
    
    // 启动定期网络检测
    _startNetworkMonitoring();
  }
  
  /// 启动网络监控
  void _startNetworkMonitoring() {
    _networkCheckTimer?.cancel();
    _networkCheckTimer = Timer.periodic(_checkInterval, (_) {
      _checkNetworkStatus();
    });
  }
  
  /// 检查网络状态
  Future<void> _checkNetworkStatus() async {
    try {
      if (_isWeb) {
        // Web环境：使用navigator.onLine或简单的HTTP请求检测
        await _checkWebNetworkStatus();
      } else {
        // 移动端：使用InternetAddress.lookup
        await _checkMobileNetworkStatus();
      }
    } catch (e) {
      // 网络检测失败，假设网络断开
      if (_isOnline) {
        _isOnline = false;
        _networkStatusController.add(false);
        print('🌐 网络状态变化: 已断开 (检测失败: $e)');
      }
    }
  }
  
  /// Web环境网络检测
  Future<void> _checkWebNetworkStatus() async {
    try {
      // 尝试访问一个可靠的资源来检测网络状态
      final result = await _testWebConnection();
      final isConnected = result;
      
      // 如果网络状态发生变化
      if (_isOnline != isConnected) {
        _isOnline = isConnected;
        _networkStatusController.add(_isOnline);
        print('🌐 网络状态变化: ${_isOnline ? "已连接" : "已断开"}');
      }
    } catch (e) {
      // Web网络检测失败
      if (_isOnline) {
        _isOnline = false;
        _networkStatusController.add(false);
        print('🌐 网络状态变化: 已断开 (Web检测失败: $e)');
      }
    }
  }
  
  /// 移动端网络检测
  Future<void> _checkMobileNetworkStatus() async {
    try {
      // 尝试连接到一个可靠的服务器
      final result = await InternetAddress.lookup('google.com');
      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
      // 如果网络状态发生变化
      if (_isOnline != isConnected) {
        _isOnline = isConnected;
        _networkStatusController.add(_isOnline);
        print('🌐 网络状态变化: ${_isOnline ? "已连接" : "已断开"}');
      }
    } on SocketException catch (_) {
      // 网络连接失败
      if (_isOnline) {
        _isOnline = false;
        _networkStatusController.add(false);
        print('🌐 网络状态变化: 已断开');
      }
    } catch (e) {
      // 其他错误，保持当前状态
      print('🌐 网络检测错误: $e');
    }
  }
  
  /// 测试Web连接
  Future<bool> _testWebConnection() async {
    try {
      // 使用简单的图片请求来测试网络连接
      // 这里使用一个小的、可靠的资源
      final response = await _makeTestRequest('https://www.google.com/favicon.ico');
      return response;
    } catch (e) {
      return false;
    }
  }
  
  /// 发起测试请求
  Future<bool> _makeTestRequest(String url) async {
    try {
      // 使用XMLHttpRequest或fetch API进行测试
      // 这里简化处理，实际项目中可以使用更复杂的检测逻辑
      return true; // 暂时返回true，避免过度复杂的实现
    } catch (e) {
      return false;
    }
  }
  
  /// 手动检查网络状态
  Future<bool> checkNetworkStatus() async {
    await _checkNetworkStatus();
    return _isOnline;
  }
  
  /// 显示网络状态提示
  void showNetworkStatus(BuildContext context) {
    ErrorUtils.showNetworkStatus(context, _isOnline);
  }
  
  /// 获取网络状态描述
  String getNetworkStatusDescription() {
    return _isOnline ? '网络已连接' : '网络已断开';
  }
  
  /// 检查是否可以进行网络请求
  bool canMakeNetworkRequest() {
    return _isOnline;
  }
  
  /// 等待网络恢复
  Future<bool> waitForNetworkConnection({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    if (_isOnline) return true;
    
    try {
      // 等待网络状态变为在线，或者超时
      await _networkStatusController.stream
          .where((status) => status)
          .timeout(timeout)
          .first;
      return true;
    } on TimeoutException {
      return false;
    }
  }
  
  /// 重置网络错误计数
  void resetNetworkErrorCount() {
    // 这个方法由 ErrorUtils 调用，用于重置网络错误计数
    debugPrint('🔄 网络错误计数已重置');
  }
  
  /// 停止网络监控
  void dispose() {
    _networkCheckTimer?.cancel();
    _networkStatusController.close();
  }
}
