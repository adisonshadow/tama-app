import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';

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
          debugPrint('🔍 获取用户信息成功: ${_user?.nickname}');
        }
      } else {
        _error = result['message'] ?? '获取用户信息失败';
        if (kIsWeb) {
          debugPrint('🔍 获取用户信息失败: $_error');
        }
      }
    } catch (e) {
      _error = '网络错误: $e';
      if (kIsWeb) {
        debugPrint('🔍 获取用户信息异常: $e');
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
          debugPrint('🔍 更新用户信息成功');
        }
        return true;
      } else {
        _error = result['message'] ?? '更新用户信息失败';
        if (kIsWeb) {
          debugPrint('🔍 更新用户信息失败: $_error');
        }
        return false;
      }
    } catch (e) {
      _error = '网络错误: $e';
      if (kIsWeb) {
        debugPrint('🔍 更新用户信息异常: $e');
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
        debugPrint('🔍 准备上传图片: ${imageFile.path}');
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
          debugPrint('🔍 图片上传成功: $filename');
        }
        return filename;
      } else {
        _error = result['message'] ?? '图片上传失败';
        if (kIsWeb) {
          debugPrint('🔍 图片上传失败: $_error');
        }
        return null;
      }
    } catch (e) {
      _error = '图片上传异常: $e';
      if (kIsWeb) {
        debugPrint('🔍 图片上传异常: $e');
      }
      return null;
    }
  }

  /// 选择图片
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      if (kIsWeb) {
        // Web 平台使用自定义的文件选择器
        debugPrint('🔍 Web平台：使用自定义文件选择器');
        
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
        debugPrint('🔍 Web平台选择图片失败: $e');
      }
      return null;
    }
  }

  /// 裁剪图片
  Future<File?> cropImage(File imageFile, {String cropType = 'avatar', BuildContext? context}) async {
    try {
      if (kIsWeb) {
        debugPrint('🔍 开始裁剪图片: ${imageFile.path}');
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: cropType == 'avatar' 
            ? const CropAspectRatio(ratioX: 1, ratioY: 1)  // 头像：1:1 正方形
            : const CropAspectRatio(ratioX: 16, ratioY: 9), // 封面：16:9 矩形
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪${cropType == 'avatar' ? '头像' : '封面'}',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: false,
            cropStyle: cropType == 'avatar' 
                ? CropStyle.circle 
                : CropStyle.rectangle,
          ),
          IOSUiSettings(
            title: '裁剪${cropType == 'avatar' ? '头像' : '封面'}',
            aspectRatioLockEnabled: true,
            minimumAspectRatio: 1.0,
          ),
          if (context != null)
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
            ),
        ],
      );

      if (croppedFile != null) {
        if (kIsWeb) {
          debugPrint('🔍 图片裁剪成功');
        }
        return File(croppedFile.path);
      }
      
      return null;
    } catch (e) {
      if (kIsWeb) {
        debugPrint('🔍 图片裁剪失败: $e');
      }
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
