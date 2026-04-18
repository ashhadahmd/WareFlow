import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';
import 'package:warehouse_management_system/core/model/inventory_model/inventory_model.dart';

class InventoryServices {
  final Dio _dio = ApiClient().dio;

  Future<List<InventoryModel>?> getInventory(
    String token,
    int warehouseID,
  ) async {
    try {
      Response response = await _dio.get(
        ApiEndpoints.inventory,
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
        return data.map((item) => InventoryModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("GET Inventory Error: ${e.response?.statusCode} - ${e.message}");
      return [];
    }
  }
}
