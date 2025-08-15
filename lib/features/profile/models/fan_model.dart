import 'package:json_annotation/json_annotation.dart';
import '../../../core/constants/app_constants.dart';

part 'fan_model.g.dart';

@JsonSerializable()
class FanModel {
  final String id;
  final String nickname;
  final String? avatar;
  final String? bio;
  @JsonKey(name: 'space_bg')
  final String? spaceBg;
  @JsonKey(name: 'follow_time')
  final String? followTime;
  @JsonKey(name: 'isFollowing')
  final bool? isFollowing;

  const FanModel({
    required this.id,
    required this.nickname,
    this.avatar,
    this.bio,
    this.spaceBg,
    this.followTime,
    this.isFollowing,
  });

  factory FanModel.fromJson(Map<String, dynamic> json) => _$FanModelFromJson(json);
  Map<String, dynamic> toJson() => _$FanModelToJson(this);

  String get avatarUrl {
    if (avatar != null && avatar!.isNotEmpty) {
      return avatar!.startsWith('http') 
          ? avatar! 
          : '${AppConstants.baseUrl}/api/image/$avatar';
    }
    return '';
  }
}
