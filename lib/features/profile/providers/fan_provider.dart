import 'package:flutter/foundation.dart';
import '../models/fan_model.dart';
import '../services/fan_service.dart';

class FanProvider extends ChangeNotifier {
  List<FanModel> _fans = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  int _currentPage = 1;

  List<FanModel> get fans => _fans;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> loadMyFollowers({bool refresh = false}) async {
    print('🔍 FanProvider - loadMyFollowers 方法开始执行');
    if (_isLoading) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _fans.clear();
      }

      _setLoading(true);
      _clearError();

      print('🔍 FanProvider - 开始加载粉丝，页码: $_currentPage');

      final response = await FanService.getMyFollowers(
        page: _currentPage,
        pageSize: 20,
      );

      print('🔍 FanProvider - API响应: $response');

      if (response['status'] == 'SUCCESS') {
        // 处理分页数据结构
        final dynamic data = response['data'];
        List<dynamic> fanData = [];
        
        print('🔍 FanProvider - 原始data: $data');
        print('🔍 FanProvider - data类型: ${data.runtimeType}');
        
        if (data is Map<String, dynamic>) {
          // 如果data是Map，尝试获取items字段或嵌套的data字段
          fanData = data['data'] ?? data['items'] ?? [];
          print('🔍 FanProvider - 从Map中提取的fanData: $fanData');
        } else if (data is List) {
          // 如果data直接是List
          fanData = data;
          print('🔍 FanProvider - data直接是List: $fanData');
        } else {
          print('🔍 FanProvider - 未知的粉丝数据结构: ${data.runtimeType}');
          fanData = [];
        }
        
        print('🔍 FanProvider - 最终解析到的粉丝数据: ${fanData.length} 条');
        
        if (fanData.isNotEmpty) {
          print('🔍 FanProvider - 第一条数据示例: ${fanData.first}');
        }
        
        final List<FanModel> newFans = fanData
            .map((json) {
              try {
                // 处理null值，确保必需字段有默认值
                final processedJson = Map<String, dynamic>.from(json);
                if (processedJson['follow_time'] == null) {
                  processedJson['follow_time'] = ''; // 提供默认值
                }
                if (processedJson['isFollowing'] == null) {
                  processedJson['isFollowing'] = false; // 提供默认值
                }
                
                final fan = FanModel.fromJson(processedJson);
                print('🔍 FanProvider - 成功解析粉丝: ${fan.nickname}');
                return fan;
              } catch (e) {
                print('❌ FanProvider - 解析粉丝失败: $e');
                print('❌ FanProvider - 失败的数据: $json');
                rethrow;
              }
            })
            .toList();

        if (refresh) {
          _fans = newFans;
        } else {
          _fans.addAll(newFans);
        }

        _currentPage++;
        _hasMore = newFans.length >= 20;
        
        print('🔍 FanProvider - 加载完成，当前粉丝总数: ${_fans.length}');
      } else {
        print('❌ FanProvider - API返回失败状态: ${response['message']}');
        _setError(response['message'] ?? '加载失败');
      }
    } catch (e) {
      print('❌ FanProvider - 加载粉丝时发生错误: $e');
      _setError('网络错误：$e');
    } finally {
      _setLoading(false);
      print('🔍 FanProvider - 加载状态设置为false');
    }
  }

  Future<void> refreshFans() async {
    await loadMyFollowers(refresh: true);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    // 在Chrome中打印错误信息到控制台
    if (kIsWeb) {
      debugPrint('❌ FanProvider Error: $error');
    }
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
