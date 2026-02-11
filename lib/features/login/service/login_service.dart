import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../model/login_response_model.dart';

class LoginService {
  final DioClient _dioClient = DioClient();

  Future<(LoginResponseModel?, String?)> login(
    String username,
    String password,
  ) async {
    try {
      final formData = FormData.fromMap({
        'username': username,
        'password': password,
      });

      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = LoginResponseModel.fromJson(response.data);
        return (data, null);
      }
      return (null, 'Login failed with status: ${response.statusCode}');
    } on DioException catch (e) {
      return (null, e.message ?? 'An unexpected error occurred');
    } catch (e) {
      return (null, e.toString());
    }
  }
}
