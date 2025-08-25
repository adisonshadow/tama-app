class AppConstants {
  // API配置
  static const String baseUrl = 'https://www.xx.com';
  // static const String baseUrl = 'http://192.168.110.77:5200';
  static const String apiPrefix = '/api';
  
  // 存储键名
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_info';
  static const String playedVideoIdsKey = 'played_video_ids';
  static const String videoTokenKey = 'video_token';
  static const String userEmailKey = 'user_email';
  
  // 网络请求配置
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  
  // 视频配置
  static const int videoPreloadCount = 3;
  static const double videoAspectRatio = 9 / 16;
  
  // UI配置
  static const double bottomBarHeight = 60.0;
  static const double actionButtonSize = 50.0;
  
  // 分页配置
  static const int defaultPageSize = 20;
}
