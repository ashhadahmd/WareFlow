import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';
import 'package:warehouse_management_system/core/model/charts_model/dount_chart_model.dart';

class ReportsInventoryCategoryServices {
  final Dio _dio = ApiClient().dio;

  Future<List<DountChartModel>> getReportsInventoryCategory(
    String token,
    int warehouseID,
  ) async {
    try {
      Response response = await _dio.get(
        ApiEndpoints.reportInventoryCategory,
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
        return data.map((item) => DountChartModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      print("Chart API Error: ${e.response?.statusCode} - ${e.message}");
      return [];
    }
  }
}
