import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';
import 'package:warehouse_management_system/core/model/orders_model/orders_model.dart';

class OrderServices {
  final Dio _dio = ApiClient().dio;

  Future<List<OrderModel>?> getOrders(String token, int warehouseID) async {
    try {
      Response response = await _dio.get(
        ApiEndpoints.orders,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'x-warehouse-id': warehouseID.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => OrderModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("GET Orders Error: ${e.response?.statusCode} - ${e.message}");
      print("--- BACKEND GIVES ERROR ---");
      print("Status Code: ${e.response?.statusCode}");

      // 🔥 YEH LINE TUMHE ASLI WAJAH BATAYEGI
      print("Server Message: ${e.response?.data}");
      return [];
    }
  }
}
