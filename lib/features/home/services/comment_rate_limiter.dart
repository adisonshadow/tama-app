import 'dart:collection';

class CommentRateLimiter {
  static final CommentRateLimiter _instance = CommentRateLimiter._internal();
  factory CommentRateLimiter() => _instance;
  CommentRateLimiter._internal();

  // 存储每个用户的评论时间记录
  final Map<String, Queue<DateTime>> _userCommentTimes = {};
  
  // 配置参数
  static const int maxCommentsPerPeriod = 100; // 5分钟内最多评论数
  static const int timeWindowMinutes = 5; // 时间窗口（分钟）

  /// 检查用户是否可以发表评论
  bool canComment(String userId) {
    final now = DateTime.now();
    final timeWindow = Duration(minutes: timeWindowMinutes);
    final cutoffTime = now.subtract(timeWindow);

    // 获取用户的评论时间队列
    if (!_userCommentTimes.containsKey(userId)) {
      _userCommentTimes[userId] = Queue<DateTime>();
    }

    final userTimes = _userCommentTimes[userId]!;

    // 移除超出时间窗口的记录
    while (userTimes.isNotEmpty && userTimes.first.isBefore(cutoffTime)) {
      userTimes.removeFirst();
    }

    // 检查是否超过限制
    if (userTimes.length >= maxCommentsPerPeriod) {
      return false;
    }

    return true;
  }

  /// 记录用户发表评论
  void recordComment(String userId) {
    final now = DateTime.now();
    
    if (!_userCommentTimes.containsKey(userId)) {
      _userCommentTimes[userId] = Queue<DateTime>();
    }

    final userTimes = _userCommentTimes[userId]!;
    userTimes.addLast(now);

    // 清理过期记录
    final timeWindow = Duration(minutes: timeWindowMinutes);
    final cutoffTime = now.subtract(timeWindow);
    
    while (userTimes.isNotEmpty && userTimes.first.isBefore(cutoffTime)) {
      userTimes.removeFirst();
    }
  }

  /// 获取用户剩余可评论数量
  int getRemainingComments(String userId) {
    final now = DateTime.now();
    final timeWindow = Duration(minutes: timeWindowMinutes);
    final cutoffTime = now.subtract(timeWindow);

    if (!_userCommentTimes.containsKey(userId)) {
      return maxCommentsPerPeriod;
    }

    final userTimes = _userCommentTimes[userId]!;
    
    // 移除超出时间窗口的记录
    while (userTimes.isNotEmpty && userTimes.first.isBefore(cutoffTime)) {
      userTimes.removeFirst();
    }

    return maxCommentsPerPeriod - userTimes.length;
  }

  /// 获取用户下次可评论时间
  DateTime? getNextCommentTime(String userId) {
    if (!_userCommentTimes.containsKey(userId)) {
      return null;
    }

    final userTimes = _userCommentTimes[userId]!;
    if (userTimes.isEmpty) {
      return null;
    }

    // 找到最早需要等待的评论时间
    final earliestComment = userTimes.first;
    final timeWindow = Duration(minutes: timeWindowMinutes);
    return earliestComment.add(timeWindow);
  }

  /// 清理过期数据
  void cleanup() {
    final now = DateTime.now();
    final timeWindow = Duration(minutes: timeWindowMinutes);
    final cutoffTime = now.subtract(timeWindow);

    _userCommentTimes.forEach((userId, userTimes) {
      while (userTimes.isNotEmpty && userTimes.first.isBefore(cutoffTime)) {
        userTimes.removeFirst();
      }
      
      // 如果用户没有评论记录，删除该用户
      if (userTimes.isEmpty) {
        _userCommentTimes.remove(userId);
      }
    });
  }
}
