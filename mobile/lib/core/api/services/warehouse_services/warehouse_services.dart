import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';
import 'package:warehouse_management_system/core/model/warehouse_model/warehouse_list_model.dart';

class WarehouseService {
  final Dio _dio = ApiClient().dio;

  // --- 1. GET: All Warehouses ---
  Future<List<WarehouseListModel>?> getWarehouses(String token) async {
    try {
      Response response = await _dio.get(
        ApiEndpoints.warehouse,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => WarehouseListModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("GET Warehouses Error: ${e.response?.data}");
      return [];
    }
  }

  // --- 2. POST: Create New Warehouse ---
  Future<bool> createWarehouse(String token, String warehouseName) async {
    try {
      //
      Response response = await _dio.post(
        ApiEndpoints.warehouse,
        data: {"name": warehouseName},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Warehouse Created Successfully!");
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      print("POST Warehouse Error: ${e.response?.data}");
      return false;
    }
  }
}
