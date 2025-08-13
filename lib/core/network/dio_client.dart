import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../../shared/services/storage_service.dart';

class DioClient {
  static late Dio _dio;
  
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
        }
        handler.next(error);
      },
    ));
    
    // 添加日志拦截器（仅在调试模式下）
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));
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
}
