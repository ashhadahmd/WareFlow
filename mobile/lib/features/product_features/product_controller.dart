import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/dummy_data/dummy_data.dart';
import 'package:warehouse_management_system/core/model/inventory_model/inventory_model.dart';

class AddProductController extends GetxController {
  List<InventoryModel> productList = <InventoryModel>[].obs;
  List<InventoryModel> foundProducts = <InventoryModel>[].obs;
  //
  int? id;
  var isLoading = false.obs;
  //
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final categoryController = TextEditingController();
  final quantityController = TextEditingController();
  final minStockController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final supplierIDController = TextEditingController();
  final warehouseIDController = TextEditingController();
  //

  @override
  void onInit() {
    super.onInit();
    // assignAll -> Data Copy Method
    productList.assignAll(DummyData().dummyInventory);
    foundProducts.assignAll(productList);
  }

  Future<bool> saveProduct() async {
    if (nameController.text.trim().isEmpty &&
        skuController.text.toUpperCase().trim().isEmpty &&
        supplierIDController.text.trim().isEmpty &&
        warehouseIDController.text.trim().isEmpty &&
        priceController.text.trim().isEmpty &&
        quantityController.text.trim().isEmpty &&
        minStockController.text.trim().isEmpty &&
        categoryController.text.trim().isEmpty &&
        locationController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Kindly Fill the Field');
      return false;
    }

    isLoading.value = true;

    try {
      await Future.delayed(Duration(seconds: 2));
      InventoryModel newProductModel = InventoryModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: nameController.text.trim(),
        sku: skuController.text.toUpperCase().trim(),
        category: categoryController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
        warehouseId: int.parse(warehouseIDController.text.trim()),
        supplierId: int.parse(supplierIDController.text.trim()),
        price: int.parse(priceController.text.trim()),
        minStock: int.parse(minStockController.text.trim()),
        location: locationController.text.trim(),
      );
      productList.add(newProductModel);
      foundProducts.assignAll(productList);
      Get.back();
      clearFields();
      Get.snackbar('Product Save', 'Product is save successfully');
      return true;
    } catch (e) {
      Get.snackbar("Error", 'Message: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void initialData(InventoryModel product) {
    id = product.id;
    nameController.text = product.name.toString();
    categoryController.text = product.category.toString();
    skuController.text = product.sku.toString();
    locationController.text = product.location.toString();
    minStockController.text = product.minStock.toString();
    priceController.text = product.price.toString();
    supplierIDController.text = product.supplierId.toString();
    warehouseIDController.text = product.warehouseId.toString();
    quantityController.text = product.quantity.toString();
  }

  Future<bool> updateProduct() async {
    if (nameController.text.trim().isEmpty &&
        skuController.text.toUpperCase().trim().isEmpty &&
        supplierIDController.text.trim().isEmpty &&
        warehouseIDController.text.trim().isEmpty &&
        priceController.text.trim().isEmpty &&
        quantityController.text.trim().isEmpty &&
        minStockController.text.trim().isEmpty &&
        categoryController.text.trim().isEmpty &&
        locationController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Kindly Fill the Field');
      return false;
    }

    isLoading.value = true;

    try {
      await Future.delayed(Duration(seconds: 2));

      int index = productList.indexWhere((item) => item.id == id);

      // index != -1 means if the index is found => (1 != 1) true is not equal to false
      if (index != -1) {
        productList[index].name = nameController.text.trim();
        productList[index].sku = skuController.text.toUpperCase().trim();
        productList[index].category = categoryController.text.trim();
        productList[index].quantity = int.parse(quantityController.text.trim());
        productList[index].minStock = int.parse(minStockController.text.trim());
        productList[index].price = int.parse(priceController.text.trim());
        productList[index].location = locationController.text.trim();
        productList[index].warehouseId = int.parse(
          warehouseIDController.text.trim(),
        );
        productList[index].supplierId = int.parse(
          supplierIDController.text.trim(),
        );

        productList.assignAll(productList.toList());
        foundProducts.assignAll(productList);

        Get.back();
        clearFields();
        Get.snackbar('Success', 'Product updated successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Product not found in list');
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", 'Message: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(int productid) async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 2));
      productList.removeWhere((item) => item.id == productid);
      foundProducts.assignAll(productList);
      Get.back();
      Get.snackbar('Successfully Deleted', 'Product is Successfully Deleted');
      return true;
    } catch (e) {
      Get.snackbar('Something Went Wrong', 'Message: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void searchProduct(String searchItem) {
    String searchKey = searchItem.toLowerCase().trim();

    if (searchKey.isEmpty) {
      foundProducts.assignAll(productList);
    } else {
      var filteredList = productList.where((item) {
        return item.name!.toLowerCase().contains(searchKey) ||
            item.sku!.toLowerCase().contains(searchKey);
      }).toList();
      foundProducts.assignAll(filteredList);
    }
  }

  void clearFields() {
    nameController.clear();
    skuController.clear();
    searchController.clear();
    supplierIDController.clear();
    warehouseIDController.clear();
    priceController.clear();
    locationController.clear();
    minStockController.clear();
    quantityController.clear();
    categoryController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
    searchController.dispose();
    locationController.dispose();
    quantityController.dispose();
    locationController.dispose();
    minStockController.dispose();
    priceController.dispose();
    supplierIDController.dispose();
    warehouseIDController.dispose();
    super.onClose();
  }
}
