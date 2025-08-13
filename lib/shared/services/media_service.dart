import '../../core/network/dio_client.dart';

class MediaService {
  static Future<Map<String, dynamic>> generateToken() async {
    try {
      final response = await DioClient.instance.get('/media/generate-token');
      return DioClient.handleApiResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}