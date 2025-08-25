import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_i18n/flutter_i18n.dart';
// 移除 dart:html 导入，改用条件编译

import '../providers/profile_provider.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  final ProfileProvider profileProvider;

  const EditProfileScreen({
    super.key,
    required this.user,
    required this.profileProvider,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  
  // 临时存储选择的图片
  File? _selectedAvatarFile;
  File? _selectedCoverFile;
  String? _tempAvatarUrl;
  String? _tempCoverUrl;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.user.nickname);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    
    if (kIsWeb) {
      // debugPrint('🔍 EditProfileScreen initState');
      // debugPrint('🔍 用户昵称: ${widget.user.nickname}');
      // debugPrint('🔍 用户简介: ${widget.user.bio}');
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(FlutterI18n.translate(context, 'profile.edit_profile.title')),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _saveProfile(widget.profileProvider),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    FlutterI18n.translate(context, 'profile.edit_profile.save'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(widget.profileProvider),
            const SizedBox(height: 30),
            _buildCoverSection(widget.profileProvider),
            const SizedBox(height: 20),
            _buildNicknameSection(),
            const SizedBox(height: 20),
            _buildBioSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(ProfileProvider profileProvider) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: _buildAvatarImage(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _isLoading ? null : () => _pickImage('avatar', profileProvider),
                child: Text(
                  FlutterI18n.translate(context, 'profile.edit_profile.select_avatar'),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection(ProfileProvider profileProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FlutterI18n.translate(context, 'profile.edit_profile.cover_title'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildCoverImage(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => _pickImage('cover', profileProvider),
                    child: Text(
                      FlutterI18n.translate(context, 'profile.edit_profile.select_cover'),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    // 优先显示选择的图片
    if (_selectedAvatarFile != null) {
      return Image.file(
        _selectedAvatarFile!,
        fit: BoxFit.cover,
      );
    }
    
    // 其次显示临时URL
    if (_tempAvatarUrl != null) {
      return Image.network(
        _tempAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    
    // 最后显示用户原有头像
    if (widget.user.avatar != null && widget.user.avatar!.isNotEmpty) {
      return Image.network(
        '${AppConstants.baseUrl}/api/image/${widget.user.avatar}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildCoverImage() {
    // 优先显示选择的图片
    if (_selectedCoverFile != null) {
      return Image.file(
        _selectedCoverFile!,
        fit: BoxFit.cover,
      );
    }
    
    // 其次显示临时URL
    if (_tempCoverUrl != null) {
      return Image.network(
        _tempCoverUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultCover();
        },
      );
    }
    
    // 最后显示用户原有封面
    if (widget.user.spaceBg != null && widget.user.spaceBg!.isNotEmpty) {
      return Image.network(
        '${AppConstants.baseUrl}/api/image/${widget.user.spaceBg}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultCover();
        },
      );
    } else {
      return _buildDefaultCover();
    }
  }

  Widget _buildDefaultCover() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNicknameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FlutterI18n.translate(context, 'profile.edit_profile.nickname'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nicknameController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: FlutterI18n.translate(context, 'profile.edit_profile.nickname_hint'),
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FlutterI18n.translate(context, 'profile.edit_profile.bio'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: FlutterI18n.translate(context, 'profile.edit_profile.bio_hint'),
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// 选择图片
  Future<void> _pickImage(String type, ProfileProvider profileProvider) async {
    try {
      if (kIsWeb) {
        // Web 平台暂时显示提示
        // debugPrint('🔍 Web平台：图片选择功能开发中');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.web_image_picker_developing')),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final imageFile = await profileProvider.pickImage();
      
      if (imageFile != null) {
        setState(() {
          if (type == 'avatar') {
            _selectedAvatarFile = imageFile;
            _tempAvatarUrl = null;
          } else {
            _selectedCoverFile = imageFile;
            _tempCoverUrl = null;
          }
        });
        
        if (kIsWeb) {
          // debugPrint('🔍 选择了${type == 'avatar' ? '头像' : '封面'}图片: ${imageFile.path}');
        }
        
        // 选择图片成功后，自动打开裁剪功能
        if (mounted) {
          // 延迟一下，确保setState完成后再打开裁剪
          Future.delayed(const Duration(milliseconds: 100), () async {
            if (mounted) {
              // 直接调用ProfileProvider的裁剪方法
              final imageFile = type == 'avatar' ? _selectedAvatarFile : _selectedCoverFile;
              if (imageFile != null) {
                final croppedFile = await widget.profileProvider.cropImage(
                  imageFile,
                  cropType: type,
                  context: context,
                );
                
                if (croppedFile != null) {
                  // 更新裁剪后的图片
                  setState(() {
                    if (type == 'avatar') {
                      _selectedAvatarFile = croppedFile;
                      _tempAvatarUrl = null;
                    } else {
                      _selectedCoverFile = croppedFile;
                      _tempCoverUrl = null;
                    }
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${type == 'avatar' ? '头像' : '封面'}裁剪成功'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            }
          });
        }
      } else {
        // 用户取消选择
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.no_image_selected')),
              backgroundColor: Colors.grey,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 选择图片失败: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
              content: Text('${FlutterI18n.translate(context, 'profile.edit_profile.image_pick_failed')}: $e'),
              backgroundColor: Colors.red,
            ),
        );
      }
    }
  }

  /// 处理 Web 平台选择的图片文件 - 暂时移除
  // void _handleWebImageFile(html.File htmlFile, String type) { ... }

  /// 更新用户信息
  Future<void> _saveProfile(ProfileProvider profileProvider) async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FlutterI18n.translate(context, 'profile.edit_profile.nickname_required')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? newAvatar;
      String? newSpaceBg;

      // 上传头像
      if (_selectedAvatarFile != null) {
        if (kIsWeb) {
          // debugPrint('🔍 开始上传头像');
        }
        
        newAvatar = await profileProvider.uploadImage(_selectedAvatarFile!);
        if (newAvatar == null) {
          throw Exception('头像上传失败');
        }
        
        if (kIsWeb) {
          // debugPrint('🔍 头像上传成功: $newAvatar');
        }
      }

      // 上传封面
      if (_selectedCoverFile != null) {
        if (kIsWeb) {
          // debugPrint('🔍 开始上传封面');
        }
        
        newSpaceBg = await profileProvider.uploadImage(_selectedCoverFile!);
        if (newSpaceBg == null) {
          throw Exception('封面上传失败');
        }
        
        if (kIsWeb) {
          // debugPrint('🔍 封面上传成功: $newSpaceBg');
        }
      }

      // 更新用户信息
      if (mounted) {
        final success = await profileProvider.updateUserInfo(
          nickname: _nicknameController.text.trim(),
          bio: _bioController.text.trim(),
          avatar: newAvatar,
          spaceBg: newSpaceBg,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.save_success')),
              backgroundColor: Colors.green,
            ),
            );
            
            // 返回上一页
            Navigator.of(context).pop();
          }
        } else {
          throw Exception(profileProvider.error ?? '更新用户信息失败');
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 保存用户信息失败: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${FlutterI18n.translate(context, 'profile.edit_profile.save_failed')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
