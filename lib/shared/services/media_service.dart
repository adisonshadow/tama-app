import '../../../core/network/dio_client.dart';

class MediaService {
  static Future<Map<String, dynamic>> generateVideoToken() async {
    try {
      final response = await DioClient.instance.get('/media/generate-token');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
  

}