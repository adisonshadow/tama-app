import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/app_constants.dart';

part 'follow_model.g.dart';

@JsonSerializable()
class FollowModel {
  final String id;
  final String nickname;
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'member_grade')
  final int memberGrade;
  @JsonKey(name: 'is_baba')
  final int isBaba;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const FollowModel({
    required this.id,
    required this.nickname,
    this.avatar,
    this.bio,
    this.memberGrade = 0,
    this.isBaba = 0,
    required this.createdAt,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) => _$FollowModelFromJson(json);
  Map<String, dynamic> toJson() => _$FollowModelToJson(this);

  String get avatarUrl {
    if (avatar != null && avatar!.isNotEmpty) {
      return avatar!.startsWith('http') 
          ? avatar! 
          : '${AppConstants.baseUrl}/api/media/img/$avatar';
    }
    return '';
  }
}
