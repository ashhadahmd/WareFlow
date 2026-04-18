import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/dummy_data/dummy_data.dart';
import 'package:warehouse_management_system/core/model/supplier_model/supplier_model.dart';

class SupplierController extends GetxController {
  List<SupplierModel> supplierList = <SupplierModel>[].obs;
  List<SupplierModel> foundSupplier = <SupplierModel>[].obs;
  int? id;
  var isLoading = false.obs;
  // final searchController = TextEditingController();
  final nameController = TextEditingController();
  final contactNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final supplierIDController = TextEditingController();
  final warehouseIDController = TextEditingController();
  //

  @override
  void onInit() {
    super.onInit();
    // assignAll -> Data Copy Method
    supplierList.assignAll(DummyData().dummySuppliers);
    foundSupplier.assignAll(supplierList);
  }

  Future<bool> saveSupplier() async {
    if (nameController.text.trim().isEmpty &&
        contactNameController.text.trim().isEmpty &&
        supplierIDController.text.trim().isEmpty &&
        warehouseIDController.text.trim().isEmpty &&
        addressController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty &&
        emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Kindly Fill the Field');
      return false;
    }

    isLoading.value = true;

    try {
      await Future.delayed(Duration(seconds: 2));
      SupplierModel newSupplierModel = SupplierModel(
        id: DateTime.now().millisecondsSinceEpoch,
        name: nameController.text.trim(),
        contactName: contactNameController.text.trim(),
        email: emailController.text.trim(),
        phone: int.parse(phoneController.text.trim()),
        address: addressController.text.trim(),
        warehouseId: int.parse(warehouseIDController.text.trim()),
      );
      supplierList.add(newSupplierModel);
      // foundProducts.assignAll(productList);
      Get.back();
      clearFields();
      Get.snackbar('Supplier Add', 'Supplier is save successfully');
      return true;
    } catch (e) {
      Get.snackbar("Error", 'Message: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void initialData(SupplierModel supplier) {
    id = supplier.id;
    nameController.text = supplier.name.toString();
    contactNameController.text = supplier.contactName.toString();
    emailController.text = supplier.email.toString();
    addressController.text = supplier.address.toString();
    phoneController.text = supplier.phone.toString();
    warehouseIDController.text = supplier.warehouseId.toString();
  }

  Future<bool> updateSupplier() async {
    if (nameController.text.trim().isEmpty &&
        contactNameController.text.trim().isEmpty &&
        supplierIDController.text.trim().isEmpty &&
        warehouseIDController.text.trim().isEmpty &&
        phoneController.text.trim().isEmpty &&
        emailController.text.trim().isEmpty &&
        addressController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Kindly Fill the Field');
      return false;
    }

    isLoading.value = true;

    try {
      await Future.delayed(Duration(seconds: 2));

      int index = supplierList.indexWhere((sup) => sup.id == id);

      // index != -1 means if the index is found => (1 != 1) true is not equal to false
      if (index != -1) {
        supplierList[index].name = nameController.text.trim();
        supplierList[index].contactName = contactNameController.text.trim();
        supplierList[index].email = emailController.text.trim();
        supplierList[index].phone = int.parse(phoneController.text.trim());
        supplierList[index].address = addressController.text.trim();
        supplierList[index].warehouseId = int.parse(
          warehouseIDController.text.trim(),
        );

        supplierList.assignAll(supplierList.toList());
        // foundProducts.assignAll(productList);

        Get.back();
        clearFields();
        Get.snackbar('Success', 'Supplier updated successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Supplier not found in list');
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", 'Message: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteSupplier(int supplierid) async {
    isLoading.value = true;
    try {
      await Future.delayed(Duration(seconds: 2));
      supplierList.removeWhere((item) => item.id == supplierid);
      // foundProducts.assignAll(productList);
      Get.back();
      Get.snackbar('Successfully Deleted', 'Supplier is Successfully Deleted');
      return true;
    } catch (e) {
      Get.snackbar('Something Went Wrong', 'Message: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // void searchProduct(String searchItem) {
  //   String searchKey = searchItem.toLowerCase().trim();

  //   if (searchKey.isEmpty) {
  //     foundProducts.assignAll(productList);
  //   } else {
  //     var filteredList = productList.where((item) {
  //       return item.name!.toLowerCase().contains(searchKey) ||
  //           item.sku!.toLowerCase().contains(searchKey);
  //     }).toList();
  //     foundProducts.assignAll(filteredList);
  //   }
  // }

  void clearFields() {
    nameController.clear();
    contactNameController.clear();
    addressController.clear();
    supplierIDController.clear();
    warehouseIDController.clear();
    phoneController.clear();
    emailController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    contactNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    supplierIDController.dispose();
    warehouseIDController.dispose();
    super.onClose();
  }
}
