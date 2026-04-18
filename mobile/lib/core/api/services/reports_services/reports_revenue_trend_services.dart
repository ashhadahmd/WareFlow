import 'package:dio/dio.dart';
import 'package:warehouse_management_system/core/api/api_client/api_client.dart';
import 'package:warehouse_management_system/core/model/charts_model/trend_chart_model.dart';

class ReportsRevenueTrendServices {
  final Dio _dio = ApiClient().dio;

  Future<TrendChartModel?> getReportsRevenueTrend(
    String token,
    int warehouseID,
  ) async {
    try {
      Response response = await _dio.get(
        ApiEndpoints.reportRevenueTrend,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'x-warehouse-id': warehouseID.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        print('🔥 RAW API DATA: ${response.data}');
        var data = TrendChartModel.fromJson(response.data);
        return data;
      } else {
        return null;
      }
    } on DioException catch (e) {
      print("Chart API Error: ${e.response?.statusCode} - ${e.message}");
      return null;
    }
  }
}
