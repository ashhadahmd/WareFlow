import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';
import 'package:warehouse_management_system/core/model/supplier_model/supplier_model.dart';

class SupplierServices {
  final Dio _dio = ApiClient().dio;

  Future<List<SupplierModel>?> getSuppliers(
    String token,
    int warehouseID,
  ) async {
    try {
      Response response = await _dio.get(
        ApiEndpoints.suppliers,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'x-warehouse-id': warehouseID.toString(),
          },
        ),
      );

      print("DEBUG: API Status Code: ${response.statusCode}");
      print("DEBUG: Raw Response Data: ${response.data}");
      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((item) => SupplierModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("GET Supplier Error: ${e.response?.statusCode} - ${e.message}");
      return [];
    }
  }
}
