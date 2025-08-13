import 'package:json_annotation/json_annotation.dart';

part 'user_space_model.g.dart';

@JsonSerializable()
class UserSpaceModel {
  final String id;
  final String nickname;
  final String avatar;
  final String? bio;
  final String? spaceBg;
  final String? followTime;

  UserSpaceModel({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.bio,
    this.spaceBg,
    this.followTime,
  });

  factory UserSpaceModel.fromJson(Map<String, dynamic> json) => _$UserSpaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserSpaceModelToJson(this);
}
