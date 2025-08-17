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

  const EditProfileScreen({
    super.key,
    required this.user,
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
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(),
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(FlutterI18n.translate(context, 'profile.edit_profile.title')),
              actions: [
                TextButton(
                  onPressed: _isLoading ? null : () => _saveProfile(profileProvider),
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
                  _buildAvatarSection(profileProvider),
                  const SizedBox(height: 30),
                  _buildCoverSection(profileProvider),
                  const SizedBox(height: 30),
                  _buildNicknameSection(),
                  const SizedBox(height: 20),
                  _buildBioSection(),
                ],
              ),
            ),
          );
        },
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
              if (_selectedAvatarFile != null)
                TextButton(
                  onPressed: _isLoading ? null : () => _cropImage('avatar'),
                  child: Text(
                    FlutterI18n.translate(context, 'profile.edit_profile.crop_avatar'),
                    style: const TextStyle(
                      color: Colors.orange,
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
                  if (_selectedCoverFile != null)
                    TextButton(
                      onPressed: _isLoading ? null : () => _cropImage('cover'),
                      child: Text(
                        FlutterI18n.translate(context, 'profile.edit_profile.crop_cover'),
                        style: const TextStyle(
                          color: Colors.orange,
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
        
        // 选择图片成功后，显示提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.image_selected', translationParams: {
                'type': type == 'avatar' ? FlutterI18n.translate(context, 'profile.edit_profile.avatar') : FlutterI18n.translate(context, 'profile.edit_profile.cover')
              })),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
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

  /// 裁剪图片
  Future<void> _cropImage(String type) async {
    try {
      if (kIsWeb) {
        // Web 平台使用 image_cropper
        debugPrint('🔍 Web平台：使用image_cropper进行裁剪');
        
        // 检查是否有选择的图片
        final hasImage = type == 'avatar' 
            ? (_selectedAvatarFile != null || _tempAvatarUrl != null)
            : (_selectedCoverFile != null || _tempCoverUrl != null);
        
        if (!hasImage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('请先选择${type == 'avatar' ? '头像' : '封面'}图片'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: '选择图片',
                  textColor: Colors.white,
                  onPressed: () {
                    final profileProvider = context.read<ProfileProvider>();
                    _pickImage(type, profileProvider);
                  },
                ),
              ),
            );
          }
          return;
        }
        
        // Web 平台暂时显示提示，因为 image_cropper 在 Web 上需要特殊处理
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.web_crop_developing', translationParams: {
                'type': type == 'avatar' ? FlutterI18n.translate(context, 'profile.edit_profile.avatar') : FlutterI18n.translate(context, 'profile.edit_profile.cover')
              })),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final imageFile = type == 'avatar' ? _selectedAvatarFile : _selectedCoverFile;
      
      if (imageFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.please_select_image_first', translationParams: {
                'type': type == 'avatar' ? FlutterI18n.translate(context, 'profile.edit_profile.avatar') : FlutterI18n.translate(context, 'profile.edit_profile.cover')
              })),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: FlutterI18n.translate(context, 'profile.edit_profile.select_image'),
                textColor: Colors.white,
                onPressed: () {
                  final profileProvider = context.read<ProfileProvider>();
                  _pickImage(type, profileProvider);
                },
              ),
            ),
          );
        }
        return;
      }

      // 获取 ProfileProvider 实例
      final profileProvider = context.read<ProfileProvider>();
      
      // 显示裁剪中提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FlutterI18n.translate(context, 'profile.edit_profile.opening_crop_interface')),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      
      // 使用新的裁剪功能
      final croppedFile = await profileProvider.cropImage(
        imageFile, 
        cropType: type,
        context: context,
      );

      if (croppedFile != null) {
        if (kIsWeb) {
          // debugPrint('🔍 图片裁剪成功，准备上传');
        }
        
        // 更新选择的文件为裁剪后的文件
        setState(() {
          if (type == 'avatar') {
            _selectedAvatarFile = croppedFile;
          } else {
            _selectedCoverFile = croppedFile;
          }
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.crop_success', translationParams: {
                'type': type == 'avatar' ? FlutterI18n.translate(context, 'profile.edit_profile.avatar') : FlutterI18n.translate(context, 'profile.edit_profile.cover')
              })),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(context, 'profile.edit_profile.crop_failed', translationParams: {
                'type': type == 'avatar' ? FlutterI18n.translate(context, 'profile.edit_profile.avatar') : FlutterI18n.translate(context, 'profile.edit_profile.cover')
              })),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: FlutterI18n.translate(context, 'common.retry'),
                textColor: Colors.white,
                onPressed: () => _cropImage(type),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (kIsWeb) {
        debugPrint('❌ 裁剪图片失败: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${FlutterI18n.translate(context, 'profile.edit_profile.crop_image_failed')}: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: FlutterI18n.translate(context, 'common.retry'),
              textColor: Colors.white,
              onPressed: () => _cropImage(type),
            ),
          ),
        );
      }
    }
  }

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
