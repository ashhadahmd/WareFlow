import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_app_bar.dart';
import 'package:warehouse_management_system/features/supplier_features/supplier_controller.dart';
import 'package:warehouse_management_system/features/suppliers/supplier_tile.dart';

class Suppliers extends StatelessWidget {
  const Suppliers({super.key});

  @override
  Widget build(BuildContext context) {
    final SupplierController getXcontroller = Get.put(SupplierController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: 'Suppliers',
          buttonText: '+ Add Supplier',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.addSupplierScreen);
          },
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Expanded(
        child: Obx(
          () => ListView.builder(
            itemCount: getXcontroller.supplierList.length,
            itemBuilder: (context, index) {
              return SupplierTile(supplier: getXcontroller.supplierList[index]);
            },
          ),
        ),
      ),
    );
  }
}
