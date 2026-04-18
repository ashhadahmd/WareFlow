import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/core/widgets/custom_text_field.dart';
import 'package:warehouse_management_system/features/supplier_features/supplier_controller.dart';

class UpdateSupplier extends StatelessWidget {
  const UpdateSupplier({super.key});

  @override
  Widget build(BuildContext context) {
    final SupplierController getXcontroller = Get.put(SupplierController());
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
            text: 'Update Supplier',
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
                hintText: '',
              ),
              CustomTextField(
                controller: getXcontroller.contactNameController,
                label: 'Contact Name',
                hintText: '',
              ),
              CustomTextField(
                controller: getXcontroller.phoneController,
                keyboardType: TextInputType.number,
                label: 'Phone Number',
                hintText: '',
              ),
              CustomTextField(
                controller: getXcontroller.emailController,
                label: 'Email',
                hintText: '',
              ),

              CustomTextField(
                controller: getXcontroller.addressController,
                label: 'Address',
                hintText: '',
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: getXcontroller.supplierIDController,
                      keyboardType: TextInputType.number,
                      label: 'Supplier ID',
                      hintText: '',
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: getXcontroller.warehouseIDController,
                      keyboardType: TextInputType.number,
                      label: 'Warehouse ID',
                      hintText: '',
                    ),
                  ),
                ],
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
                        await getXcontroller.updateSupplier();
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
