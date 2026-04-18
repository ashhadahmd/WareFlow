import 'package:dio/dio.dart';

class ApiClient {
  // BaseURL
  static const String baseUrl = "https://wareflow-vk1u.onrender.com/";

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String warehouse = '/warehouses/';
  static const String inventory = '/inventory/';
  static const String suppliers = '/suppliers/';
  static const String orders = '/orders/';
  static const String reportInventoryCategory =
      '/reports/inventory-by-category';
  static const String reportRevenueTrend = '/reports/revenue-trend';
}
