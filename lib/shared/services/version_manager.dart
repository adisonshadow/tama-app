import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'version_check_service.dart';
import '../widgets/version_update_dialog.dart';

class VersionManager {
  static final VersionManager _instance = VersionManager._internal();
  factory VersionManager() => _instance;
  VersionManager._internal();

  static const String _lastCheckKey = 'last_version_check';
  static const String _lastVersionKey = 'last_version';
  static const Duration _checkInterval = Duration(hours: 24); // 24小时检查一次

  /// 在应用启动时检查版本更新
  Future<void> checkVersionOnStartup(BuildContext context) async {
    try {
      // 检查是否需要检查版本
      if (!await _shouldCheckVersion()) {
        return;
      }

      // 执行版本检查
      final versionInfo = await VersionCheckService().checkVersion();
      
      if (versionInfo != null && versionInfo.hasUpdate) {
        // 记录检查时间
        await _recordVersionCheck();
        
        // 显示版本更新对话框
        if (context.mounted) {
          _showVersionUpdateDialog(context, versionInfo);
        }
      }
    } catch (e) {
      print('启动时版本检查失败: $e');
      // 启动时版本检查失败不影响应用正常使用，只记录日志
    }
  }

  /// 手动检查版本更新
  Future<void> checkVersionManually(BuildContext context) async {
    try {
      // 显示检查中提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text(FlutterI18n.translate(context, 'version.manager.checking')),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 执行版本检查
      final versionInfo = await VersionCheckService().checkVersion();

      if (versionInfo != null && versionInfo.hasUpdate) {
        // 记录检查时间
        await _recordVersionCheck();
        
        // 显示版本更新对话框
        if (context.mounted) {
          _showVersionUpdateDialog(context, versionInfo);
        }
      } else {
        // 显示无更新提示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'version.manager.up_to_date')),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('手动版本检查失败: $e');

      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FlutterI18n.translate(context, 'version.manager.version_check_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 判断是否需要检查版本
  Future<bool> _shouldCheckVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString(_lastCheckKey);
      final lastVersion = prefs.getString(_lastVersionKey);
      
      if (lastCheck == null || lastVersion == null) {
        return true;
      }

      final lastCheckTime = DateTime.parse(lastCheck);
      final now = DateTime.now();
      
      // 检查时间间隔
      if (now.difference(lastCheckTime) < _checkInterval) {
        return false;
      }

      // 检查版本是否变化
      final currentVersion = await VersionCheckService().getCurrentVersion();
      if (currentVersion != lastVersion) {
        return true;
      }

      return false;
    } catch (e) {
      print('检查版本检查条件失败: $e');
      return true; // 出错时默认检查
    }
  }

  /// 记录版本检查
  Future<void> _recordVersionCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = await VersionCheckService().getCurrentVersion();
      
      await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());
      await prefs.setString(_lastVersionKey, currentVersion);
    } catch (e) {
      print('记录版本检查失败: $e');
    }
  }

  /// 显示版本更新对话框
  void _showVersionUpdateDialog(BuildContext context, VersionInfo versionInfo) {
    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: !versionInfo.forceUpdate,
          builder: (context) => VersionUpdateDialog(
            versionInfo: versionInfo,
            onCancel: versionInfo.forceUpdate ? null : () {
              try {
                Navigator.of(context).pop();
              } catch (e) {
                print('关闭版本更新对话框失败: $e');
              }
            },
          ),
        );
      }
    } catch (e) {
      print('显示版本更新对话框失败: $e');
    }
  }

  /// 获取当前应用版本
  Future<String> getCurrentVersion() async {
    return await VersionCheckService().getCurrentVersion();
  }

  /// 重置版本检查记录（用于测试）
  Future<void> resetVersionCheckRecord() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastCheckKey);
      await prefs.remove(_lastVersionKey);
    } catch (e) {
      print('重置版本检查记录失败: $e');
    }
  }
}
