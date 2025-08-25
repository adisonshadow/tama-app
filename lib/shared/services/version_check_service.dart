import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../core/network/dio_client.dart';

class VersionInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String changelog;
  final bool forceUpdate;
  final bool hasUpdate;

  VersionInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.changelog,
    required this.forceUpdate,
    required this.hasUpdate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      currentVersion: json['currentVersion'] ?? '',
      latestVersion: json['latestVersion'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      changelog: json['changelog'] ?? '',
      forceUpdate: json['forceUpdate'] ?? false,
      hasUpdate: json['hasUpdate'] ?? false,
    );
  }
}

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  /// 检查版本更新
  Future<VersionInfo?> checkVersion() async {
    try {
      // 获取当前应用版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // 获取平台信息
      String platform = 'unknown';
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }

      // 调用版本检查API
      final response = await DioClient.instance.post(
        '/version/check',
        data: {
          'currentVersion': currentVersion,
          'platform': platform,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'SUCCESS' && data['data'] != null) {
          return VersionInfo.fromJson(data['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('版本检查失败: $e');
      return null;
    }
  }

  /// 下载新版本
  Future<bool> downloadUpdate(String downloadUrl) async {
    try {
      if (await canLaunchUrl(Uri.parse(downloadUrl))) {
        return await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print('下载更新失败: $e');
      return false;
    }
  }

  /// 获取应用版本信息
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return 'unknown';
    }
  }
}
