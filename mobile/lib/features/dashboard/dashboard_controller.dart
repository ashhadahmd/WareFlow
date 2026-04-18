import 'dart:async';
import 'package:get/state_manager.dart';
import 'package:warehouse_management_system/core/api/services/inventory_services/inventory_services.dart';
import 'package:warehouse_management_system/core/api/services/order_services/order_services.dart';
import 'package:warehouse_management_system/core/api/services/reports_services/reports_inventory_category_services.dart';
import 'package:warehouse_management_system/core/api/services/reports_services/reports_revenue_trend_services.dart';
import 'package:warehouse_management_system/core/api/services/supplier_services/supplier_services.dart';
import 'package:warehouse_management_system/core/get_storage/get_storage.dart';
import 'package:warehouse_management_system/core/model/charts_model/dount_chart_model.dart';

class DashboardController extends GetxController {
  String get warehouseToken => GetAppStorage.readData();
  String get warehouseID => GetAppStorage.readWarehouseID_Data().toString();
  String get warehouseName =>
      GetAppStorage.readWarehouseName(); // Settings screen may show karonga
  RxList dountChartlist = <DountChartModel>[].obs;
  //
  var completedOrdersData = 0.obs;
  var inventoryValueData = 0.obs;
  var totalRevenueData = 0.obs;
  var activeSupplierData = 0.obs;
  //
  var dountChartValue = 0.0.obs;
  var chartLabels = <String>[].obs;
  var chartValues = <double>[].obs;
  //

  @override
  void onInit() {
    super.onInit();
    dashboardData();
  }

  Future<void> dashboardData() async {
    await completedOrders();
    await inventoryValue();
    await totalRevenue();
    await activeSupplier();
    await dountChartData();
    await lineChartData();
  }
  //

  Future<void> completedOrders() async {
    // print("DEBUG: Fetching for Warehouse ID: $warehouseID");
    var allOrders = await OrderServices().getOrders(
      warehouseToken,
      int.parse(warehouseID),
    );

    if (allOrders != null && allOrders.isNotEmpty) {
      completedOrdersData.value = allOrders
          .where((item) => item.status.toString().toLowerCase() == 'completed')
          .length;
    }
  }

  Future<void> inventoryValue() async {
    var allInventoryValue = await InventoryServices().getInventory(
      warehouseToken,
      int.parse(warehouseID),
    );

    double totalTempValue = 0.0;
    //
    for (int i = 0; i < allInventoryValue!.length; i++) {
      var items = allInventoryValue[i];
      if (items.warehouseId.toString() == warehouseID.toString()) {
        double total = items.quantity!.toDouble() * items.price!.toDouble();
        totalTempValue = totalTempValue + total;
      }
    }

    inventoryValueData.value = totalTempValue.toInt();
    print(inventoryValueData);
  }

  Future<void> totalRevenue() async {
    var allTotalRevenue = await OrderServices().getOrders(
      warehouseToken,
      int.parse(warehouseID),
    );

    double totalTempRevenue = 0.0;

    for (int i = 0; i < allTotalRevenue!.length; i++) {
      var item = allTotalRevenue[i];
      print("Checking Item: ${item.warehouseId} == $warehouseID");
      if (item.warehouseId.toString() == warehouseID.toString() &&
          item.status!.toLowerCase() == 'completed' &&
          item.orderType!.toLowerCase() == 'outbound') {
        totalTempRevenue = totalTempRevenue + item.totalValue!.toDouble();
      }
    }
    totalRevenueData.value = totalTempRevenue.toInt();
    print(totalRevenueData);
  }

  Future<void> activeSupplier() async {
    var allActiveSuppliers = await SupplierServices().getSuppliers(
      warehouseToken,
      int.parse(warehouseID),
    );

    if (allActiveSuppliers != null && allActiveSuppliers.isNotEmpty) {
      activeSupplierData.value = allActiveSuppliers
          .where(
            (active) =>
                active.status?.toLowerCase() == 'active' &&
                active.warehouseId.toString() == warehouseID.toString(),
          )
          .length;
    }
  }

  // ==================================================== //

  // Charts Functions

  Future<void> dountChartData() async {
    dountChartlist.clear();

    var data = await ReportsInventoryCategoryServices()
        .getReportsInventoryCategory(warehouseToken, int.parse(warehouseID));

    if (data.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
      dountChartlist.assignAll(data);
      dountChartValue.value = data.fold(0.0, (sum, item) => (sum + item.value));
    }
    print('Dount Chart Data: ${dountChartValue.value}');
  }

  Future<void> lineChartData() async {
    chartLabels.clear();
    chartValues.clear();
    var data = await ReportsRevenueTrendServices().getReportsRevenueTrend(
      warehouseToken,
      int.parse(warehouseID),
    );

    if (data != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (data.labels != null) {
      chartLabels.assignAll(
        data.labels!.map((e) => e.toString()).toList(),
      );
    }

    if (data.value != null) {
      chartValues.assignAll(
        data.value!.map((item) => double.tryParse(item.toString()) ?? 0.0).toList(),
      );
    }
    }
  }
}
