import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/core/widgets/custom_text_field.dart';
import 'package:warehouse_management_system/features/product_features/product_controller.dart';

class UpdateProduct extends StatelessWidget {
  const UpdateProduct({super.key});

  @override
  Widget build(BuildContext context) {
    final AddProductController getXcontroller = Get.put(AddProductController());

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          surfaceTintColor: AppColors.transparentColor,
          scrolledUnderElevation: 0,
          title: CustomText(
            text: 'Update Product',
            color: AppColors.blackColor,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomTextField(
                controller: getXcontroller.nameController,
                label: 'Name',
                hintText: 'write product name',
              ),
              CustomTextField(
                controller: getXcontroller.categoryController,
                label: 'Category',
                hintText: '',
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: getXcontroller.skuController,
                      label: 'SKU',
                      hintText: 'SKU number',
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: getXcontroller.quantityController,
                      keyboardType: TextInputType.number,
                      label: 'Quantity',
                      hintText: '',
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: getXcontroller.locationController,
                label: 'Location',
                hintText: '',
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: getXcontroller.minStockController,
                      keyboardType: TextInputType.number,
                      label: 'Minimum Stock',
                      hintText: '',
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: getXcontroller.priceController,
                      keyboardType: TextInputType.number,
                      label: 'Price',
                      hintText: '',
                    ),
                  ),
                ],
              ),
              CustomTextField(
                controller: getXcontroller.supplierIDController,
                keyboardType: TextInputType.number,
                label: 'Supplier ID',
                hintText: '',
              ),
              CustomTextField(
                controller: getXcontroller.warehouseIDController,
                keyboardType: TextInputType.number,
                label: 'Warehouse ID',
                hintText: '',
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(color: AppColors.backgroundColor),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Cancel",
                    color: AppColors.greyColor.withValues(alpha: 0.2),
                    textColor: AppColors.blackColor,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      text: "Add",
                      isLoading: getXcontroller.isLoading.value,
                      onPressed: () async {
                        if (getXcontroller.isLoading.value) return;
                        await getXcontroller.updateProduct();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
