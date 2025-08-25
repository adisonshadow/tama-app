import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'package:path_provider/path_provider.dart';

import '../../../shared/models/user_model.dart';
import '../../../core/network/dio_client.dart';

class ProfileProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取当前用户信息
  Future<void> getCurrentUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await DioClient.instance.get('/auth/me');
      final result = DioClient.handleApiResponse(response);
      
      if (result['status'] == 'SUCCESS') {
        final userData = result['data'];
        _user = UserModel.fromJsonSafe(userData);
        if (kIsWeb) {
          // debugPrint('🔍 获取用户信息成功: ${_user?.nickname}');
        }
      } else {
        _error = result['message'] ?? '获取用户信息失败';
        if (kIsWeb) {
          debugPrint('❌ 获取用户信息失败: $_error');
        }
      }
    } catch (e) {
      _error = '网络错误: $e';
      if (kIsWeb) {
        debugPrint('❌ 获取用户信息异常: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新用户信息
  Future<bool> updateUserInfo({
    String? nickname,
    String? bio,
    String? avatar,
    String? spaceBg,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await DioClient.instance.post('/my/updateMyUserInfo', data: {
        if (nickname != null) 'nickname': nickname,
        if (bio != null) 'bio': bio,
        if (avatar != null) 'avatar': avatar,
        if (spaceBg != null) 'space_bg': spaceBg,
      });

      final result = DioClient.handleApiResponse(response);
      
      if (result['status'] == 'SUCCESS') {
        // 更新本地用户信息
        if (_user != null) {
          _user = _user!.copyWith(
            nickname: nickname ?? _user!.nickname,
            bio: bio ?? _user!.bio,
            avatar: avatar ?? _user!.avatar,
            spaceBg: spaceBg ?? _user!.spaceBg,
          );
        }
        
        if (kIsWeb) {
          // debugPrint('🔍 更新用户信息成功');
        }
        return true;
      } else {
        _error = result['message'] ?? '更新用户信息失败';
        if (kIsWeb) {
          debugPrint('❌ 更新用户信息失败: $_error');
        }
        return false;
      }
    } catch (e) {
      _error = '网络错误: $e';
      if (kIsWeb) {
        debugPrint('❌ 更新用户信息异常: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 上传图片
  Future<String?> uploadImage(File imageFile) async {
    try {
      if (kIsWeb) {
        // debugPrint('🔍 准备上传图片: ${imageFile.path}');
      }

      // 创建FormData
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await DioClient.instance.post('/upload/image', data: formData);
      final result = DioClient.handleApiResponse(response);
      
      if (result['status'] == 'SUCCESS') {
        final filename = result['data']['filename'];
        if (kIsWeb) {
          // debugPrint('🔍 图片上传成功: $filename');
        }
        return filename;
      } else {
        _error = result['message'] ?? '图片上传失败';
        if (kIsWeb) {
          debugPrint('❌ 图片上传失败: $_error');
        }
        return null;
      }
    } catch (e) {
      _error = '图片上传异常: $e';
      if (kIsWeb) {
        debugPrint('❌ 图片上传异常: $e');
      }
      return null;
    }
  }

  /// 选择图片
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      if (kIsWeb) {
        // Web 平台使用自定义的文件选择器
        // debugPrint('🔍 Web平台：使用自定义文件选择器');
        
        // 在 Web 平台上，我们无法直接使用 image_picker
        // 但可以通过其他方式实现
        // 这里暂时返回 null，让调用方知道需要特殊处理
        return null;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ Web平台选择图片失败: $e');
      }
      return null;
    }
  }

  /// 裁剪图片
  Future<File?> cropImage(File imageFile, {String cropType = 'avatar', BuildContext? context}) async {
    try {
      if (kIsWeb) {
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.web_platform_crop_developing')),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      if (context == null) {
        debugPrint('❌ 裁剪方法需要BuildContext参数');
        return null;
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      debugPrint('🔍 图片文件读取成功，大小: ${imageBytes.length} bytes');
      
      final aspectRatio = cropType == 'avatar' ? 1.0 : 16 / 9;
      debugPrint('🔍 设置裁剪比例: $aspectRatio');

      if (context.mounted) {
        debugPrint('🔍 准备显示裁剪界面');
        
        final result = await Navigator.of(context).push<Uint8List?>(
          MaterialPageRoute(
            builder: (context) {
              final cropController = CropController();
              
              return Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  title: Text(FlutterI18n.translate(context, 'profile.edit_profile.crop_title', translationParams: {
                    'type': cropType == 'avatar' 
                        ? FlutterI18n.translate(context, 'profile.edit_profile.avatar')
                        : FlutterI18n.translate(context, 'profile.edit_profile.cover')
                  })),
                  actions: [
                    TextButton(
                      onPressed: () {
                        debugPrint('🔍 用户点击完成按钮，开始裁剪');
                        cropController.crop();
                      },
                      child: Text(
                        FlutterI18n.translate(context, 'profile.edit_profile.crop_complete'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                body: Crop(
                  image: imageBytes,
                  controller: cropController,
                  onCropped: (result) {
                    debugPrint('🔍 裁剪完成回调被触发，结果类型: ${result.runtimeType}');
                    
                    // 根据官方示例，使用CropSuccess和CropFailure
                    switch(result) {
                      case CropSuccess(:final croppedImage):
                        debugPrint('🔍 裁剪成功，图片大小: ${croppedImage.length} bytes');
                        Navigator.of(context).pop(croppedImage);
                      case CropFailure(:final cause):
                        debugPrint('❌ 裁剪失败: $cause');
                        Navigator.of(context).pop();
                    }
                  },
                  aspectRatio: aspectRatio,
                  baseColor: Colors.blue.shade900,
                  maskColor: Colors.white.withAlpha(100),
                  radius: cropType == 'avatar' ? 0 : 20,
                  interactive: true,
                  fixCropRect: false,
                  onStatusChanged: (status) {
                    debugPrint('🔍 裁剪状态变化: $status');
                  },
                ),
              );
            },
          ),
        );

        debugPrint('🔍 裁剪界面返回，结果: ${result != null ? "成功" : "失败"}');
        
        if (result != null) {
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(result);
          
          debugPrint('🔍 图片裁剪成功，保存到: ${tempFile.path}');
          return tempFile;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ 图片裁剪异常: $e');
      return null;
    }
  }

  /// 更新用户信息
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// 清除用户信息
  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
