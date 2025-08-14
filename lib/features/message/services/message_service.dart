import '../models/message_model.dart';

class MessageService {
  /// 获取消息列表（模拟API）
  static Future<Map<String, dynamic>> getMessages({
    int page = 1,
    int pageSize = 20,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    
    // 模拟数据
    final List<MessageModel> messages = [];
    
    if (page == 1) {
      // 第一页：系统消息
      messages.add(MessageModel(
        id: 'system_001',
        nickname: '系统',
        avatar: null,
        message: '欢迎加入我们，一起分享快乐🎉',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ));
      
      // 添加一些模拟消息
      // messages.add(MessageModel(
      //   id: 'user_001',
      //   nickname: '张三',
      //   avatar: 'avatar1.jpg',
      //   message: '你好，很高兴认识你！',
      //   timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      //   isRead: true,
      // ));
      
      // messages.add(MessageModel(
      //   id: 'user_002',
      //   nickname: '李四',
      //   avatar: 'avatar2.jpg',
      //   message: '你的视频很棒，继续加油！',
      //   timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      //   isRead: false,
      // ));
    } else if (page == 2) {
      // 第二页：更多模拟消息
      // messages.add(MessageModel(
      //   id: 'user_003',
      //   nickname: '王五',
      //   avatar: 'avatar3.jpg',
      //   message: '请问这个功能怎么使用？',
      //   timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      //   isRead: true,
      // ));
      
      // messages.add(MessageModel(
      //   id: 'user_004',
      //   nickname: '赵六',
      //   avatar: 'avatar4.jpg',
      //   message: '谢谢分享，学到了很多！',
      //   timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      //   isRead: false,
      // ));
    }
    
    // 模拟分页逻辑
    final hasMore = page < 1; // 最多3页数据
    
    return {
      'status': 'SUCCESS',
      'message': '获取消息成功',
      'data': {
        'messages': messages.map((msg) => msg.toJson()).toList(),
        'hasMore': hasMore,
        'total': page == 1 ? 5 : 2, // 总消息数
      },
    };
  }
}
