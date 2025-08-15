import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: 'userId')
  final String userId;
  
  final String email;
  final String nickname;
  final String? avatar;
  final String? bio;
  final String? spaceBg;
  
  @JsonKey(name: 'member_grade', defaultValue: 0)
  final int memberGrade;
  
  @JsonKey(name: 'is_baba', defaultValue: 0)
  final int isBaba;
  
  final String? token;

  const UserModel({
    required this.userId,
    required this.email,
    required this.nickname,
    this.avatar,
    this.bio,
    this.spaceBg,
    required this.memberGrade,
    this.isBaba = 0,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  /// 更健壮的JSON解析方法，处理可能的null值和类型转换问题
  factory UserModel.fromJsonSafe(Map<String, dynamic> json) {
    try {
      return UserModel(
        userId: json['userId']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        nickname: json['nickname']?.toString() ?? '',
        avatar: json['avatar']?.toString(),
        bio: json['bio']?.toString(),
        spaceBg: json['space_bg']?.toString(),
        memberGrade: _safeIntFromJson(json['member_grade']),
        isBaba: _safeIntFromJson(json['is_baba']),
        token: json['token']?.toString(),
      );
    } catch (e) {
      throw FormatException('Failed to parse UserModel from JSON: $e\nJSON: $json');
    }
  }
  
  /// 安全地将JSON值转换为int
  static int _safeIntFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? userId,
    String? email,
    String? nickname,
    String? avatar,
    String? bio,
    String? spaceBg,
    int? memberGrade,
    int? isBaba,
    String? token,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      spaceBg: spaceBg ?? this.spaceBg,
      memberGrade: memberGrade ?? this.memberGrade,
      isBaba: isBaba ?? this.isBaba,
      token: token ?? this.token,
    );
  }
}
