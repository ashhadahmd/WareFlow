import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:warehouse_management_system/core/api/services/warehouse_services/warehouse_services.dart';
import 'package:warehouse_management_system/core/get_storage/get_storage.dart';
import 'package:warehouse_management_system/core/model/warehouse_model/warehouse_list_model.dart';

class SelectWarehouseController extends GetxController {
  RxList warehouses = <WarehouseListModel>[].obs;
  String warehouseToken = GetAppStorage.readData();
  var isLoading = false.obs;
  final warehouseNameController = TextEditingController();
  //

  @override
  void onInit() {
    super.onInit();
    fetchWarehouses();
  }

  Future<bool> createWarehouse() async {
    if (warehouseNameController.text.isEmpty) {
      Get.snackbar('Error', 'Kindly Fill it properly');
      return false;
    }

    isLoading.value = true;

    try {
      String warehouse = warehouseNameController.text.trim();

      bool success = await WarehouseService().createWarehouse(
        warehouseToken,
        warehouse,
      );
      if (success != false) {
        await fetchWarehouses();
        clearFields();
        Get.back();
        Get.snackbar('Success', 'Warehouse Created Successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Warehouse Not created');
        return false;
      }
    } catch (e) {
      print('Something Went Wrong: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWarehouses() async {
    if (warehouseToken.isEmpty) {
      print("Error: Token not found");
      return;
    }

    isLoading.value = true;

    try {
      var data = await WarehouseService().getWarehouses(warehouseToken);
      if (data != null) {
        warehouses.assignAll(data);
      }
    } catch (e) {
      print('Fetch List Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    warehouseNameController.clear();
  }

  @override
  void onClose() {
    warehouseNameController;
    super.onClose();
  }
}
