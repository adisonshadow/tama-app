import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/auth_state_manager.dart';
import '../../shared/utils/error_utils.dart';

class DioClient {
  static late Dio _dio;
  
  // 错误重试配置
  static const int _maxRetries = 2;
  static const Duration _retryDelay = Duration(seconds: 1);
  
  // 网络错误类型
  static const String _networkErrorType = 'network_error';
  static const String _timeoutErrorType = 'timeout_error';
  static const String _serverErrorType = 'server_error';
  static const String _authErrorType = 'auth_error';
  
  static void init() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl + AppConstants.apiPrefix,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: const {
        'Content-Type': 'application/json',
      },
      // 关键：不抛出非200状态码的异常
      validateStatus: (status) {
        return status != null && status < 500; // 接受所有非5xx状态码
      },
    ));
    
    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自动添加token
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) async {
        // 处理401错误，清除token
        if (error.response?.statusCode == 401) {
          await StorageService.clearToken();
          await StorageService.clearUser();
          await StorageService.clearVideoToken();
          
          // 设置全局认证失效标志
          AuthStateManager.setAuthExpired(true);
        }
        
        // 记录错误类型
        _logErrorType(error);
        
        handler.next(error);
      },
    ));
    
    // 添加重试拦截器
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      logPrint: (message) => print('🔄 Retry: $message'),
      retries: _maxRetries,
      retryDelays: List.generate(_maxRetries, (index) => _retryDelay * (index + 1)),
    ));
    
    // 添加日志拦截器（仅在调试模式下）
    // _dio.interceptors.add(LogInterceptor(
    //   requestBody: true,
    //   responseBody: true,
    //   logPrint: (object) => print(object),
    // ));
  }
  
  static Dio get instance => _dio;
  
  /// 公共方法：处理API响应，统一处理成功和错误情况
  static Map<String, dynamic> handleApiResponse(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;
    
    // 如果响应数据是Map类型，直接返回
    if (data is Map<String, dynamic>) {
      return data;
    }
    
    // 如果不是Map类型，构造一个标准格式
    return {
      'status': statusCode == 200 ? 'SUCCESS' : 'ERROR',
      'message': statusCode == 200 ? '操作成功' : '操作失败',
      'data': data,
      'statusCode': statusCode,
    };
  }
  
  /// 公共方法：检查API响应是否成功
  static bool isApiSuccess(Map<String, dynamic> response) {
    return response['status'] == 'SUCCESS';
  }
  
  /// 公共方法：获取API错误消息
  static String getApiErrorMessage(Map<String, dynamic> response) {
    return response['message'] ?? '未知错误';
  }
  
  /// 公共方法：获取API数据
  static dynamic getApiData(Map<String, dynamic> response) {
    return response['data'];
  }
  
  /// 记录错误类型
  static void _logErrorType(DioException error) {
    String errorType;
    String errorMessage;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorType = _timeoutErrorType;
        errorMessage = '请求超时，请检查网络连接';
        break;
      case DioExceptionType.connectionError:
        errorType = _networkErrorType;
        errorMessage = '网络连接失败，请检查网络设置';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.statusCode != null) {
          if (error.response!.statusCode! >= 500) {
            errorType = _serverErrorType;
            errorMessage = '服务器错误，请稍后重试';
          } else if (error.response!.statusCode! == 401) {
            errorType = _authErrorType;
            errorMessage = '身份验证失败，请重新登录';
          } else {
            errorType = 'client_error';
            errorMessage = '请求失败，请检查输入参数';
          }
        } else {
          errorType = 'unknown_error';
          errorMessage = '未知错误';
        }
        break;
      default:
        errorType = 'unknown_error';
        errorMessage = '网络请求失败';
    }
    
    // 使用错误工具类记录错误
    print('🔍 Dio Error Type: $errorType, Message: $errorMessage');
  }
  
  /// 公共方法：安全执行网络请求，带错误处理
  static Future<Map<String, dynamic>> safeRequest(
    Future<Response> Function() requestFunction, {
    String? errorKey,
    BuildContext? context,
  }) async {
    try {
      final response = await requestFunction();
      return handleApiResponse(response);
    } on DioException catch (e) {
      final errorMessage = _getErrorMessage(e);
      
      // 如果有上下文，显示用户友好的错误提示
      if (context != null && context.mounted) {
        ErrorUtils.showNetworkError(
          context,
          errorMessage,
          errorKey: errorKey,
        );
      }
      
      // 重新抛出错误，让调用者处理
      rethrow;
    } catch (e) {
      final errorMessage = '请求失败: $e';
      
      // 如果有上下文，显示用户友好的错误提示
      if (context != null && context.mounted) {
        ErrorUtils.showError(
          context,
          errorMessage,
          errorKey: errorKey,
        );
      }
      
      rethrow;
    }
  }
  
  /// 获取用户友好的错误消息
  static String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '请求超时，请检查网络连接';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络设置';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode != null) {
          if (error.response!.statusCode! >= 500) {
            return '服务器错误，请稍后重试';
          } else if (error.response!.statusCode! == 401) {
            return '身份验证失败，请重新登录';
          } else if (error.response!.statusCode! == 404) {
            return '请求失败，请检查输入参数';
          } else if (error.response!.statusCode! == 403) {
            return '没有权限访问该资源';
          } else {
            return '请求失败，请检查输入参数';
          }
        }
        return '请求失败';
      default:
        return '网络请求失败';
    }
  }

}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Function(String) logPrint;
  final int retries;
  final List<Duration> retryDelays;
  
  RetryInterceptor({
    required this.dio,
    required this.logPrint,
    required this.retries,
    required this.retryDelays,
  });
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;
    
    if (retryCount < retries && _shouldRetry(err)) {
      logPrint('重试请求 (${retryCount + 1}/$retries)');
      
      // 等待延迟时间
      await Future.delayed(retryDelays[retryCount]);
      
      // 更新重试计数
      extra['retryCount'] = retryCount + 1;
      
      // 重新发送请求
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 重试失败，继续处理错误
      }
    }
    
    handler.next(err);
  }
  
  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    // 只对网络相关错误进行重试
    return err.type == DioExceptionType.connectionError ||
           err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           (err.type == DioExceptionType.badResponse && 
            err.response?.statusCode != null && 
            err.response!.statusCode! >= 500);
  }
}
