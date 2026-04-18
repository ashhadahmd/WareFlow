import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';

class AuthServices {
  final Dio _dio = ApiClient().dio;
  //
  Future<String?> loginUser(String email, String password) async {
    try {
      FormData formData = FormData.fromMap({
        "grant_type": "password",
        "username": email,
        "password": password,
      });

      final response = await _dio.post(
        ApiEndpoints.login,
        data: formData,
        options: Options(contentType: "application/x-www-form-urlencoded"),
      );

      if (response.statusCode == 200) {
        String token = response.data['access_token'];
        print("Login Successful! Token: $token");
        return token;
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMSG = e.response?.data['detail'];
        print('Login Error: $errorMSG');
        throw errorMSG;
      }
      return null;
    }
  }

  //
  Future<bool> signUpUser(String name, String email, String password) async {
    try {
      Response response = await _dio.post(
        ApiEndpoints.register,
        data: {"name": name, "email": email, "password": password},
      );

      // 201 ya 200 ka matlab hai User Create ho gaya
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("SignUp Successful: ${response.data}");
        return true;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        String errorMSG = e.response?.data['detail'];
        print('Sign In Error: $errorMSG');
        throw errorMSG;
      }
    }
    return false;
  }
}
