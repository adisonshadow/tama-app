import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/app_constants.dart';

part 'follow_model.g.dart';

@JsonSerializable()
class FollowModel {
  final String id;
  final String nickname;
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'space_bg')
  final String? spaceBg;
  @JsonKey(name: 'follow_time')
  final String followTime;

  const FollowModel({
    required this.id,
    required this.nickname,
    this.avatar,
    this.bio,
    this.spaceBg,
    required this.followTime,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) => _$FollowModelFromJson(json);
  Map<String, dynamic> toJson() => _$FollowModelToJson(this);

  String get avatarUrl {
    if (avatar != null && avatar!.isNotEmpty) {
      return avatar!.startsWith('http') 
          ? avatar! 
          : '${AppConstants.baseUrl}/api/image/$avatar';
    }
    return '';
  }
}
