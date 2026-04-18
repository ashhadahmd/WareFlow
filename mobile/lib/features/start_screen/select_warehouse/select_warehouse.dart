import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/get_storage/get_storage.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/core/widgets/custom_text_field.dart';
import 'package:warehouse_management_system/features/bottom_navigation/bottom_navi_controller.dart';
import 'package:warehouse_management_system/features/dashboard/dashboard_controller.dart';
import 'package:warehouse_management_system/features/start_screen/select_warehouse/select_warehouse_controller.dart';

class SelectWarehouse extends StatefulWidget {
  const SelectWarehouse({super.key});

  @override
  State<SelectWarehouse> createState() => _SelectWarehouseState();
}

class _SelectWarehouseState extends State<SelectWarehouse> {
  final SelectWarehouseController getXController = Get.put(
    SelectWarehouseController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          text: 'WAREHOUSES',
          color: AppColors.blackColor,
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // Create New Section
              Container(
                height: 140.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: createWarehouseWidget(() => showCreateWarehouseDialog()),
              ),
              SizedBox(height: 15.h),
              // Actual List
              Expanded(child: warehousesContainer()),
            ],
          ),
        ),
      ),
    );
  }

  Widget createWarehouseWidget(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: Colors.grey.shade100,
            child: Icon(Icons.add, color: AppColors.greyColor, size: 28.r),
          ),
          SizedBox(height: 8.h),
          CustomText(
            text: 'CREATE NEW',
            color: AppColors.greyColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  void showCreateWarehouseDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: "New Warehouse",
                  color: AppColors.blackColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 15.h),
                CustomTextField(
                  controller: getXController.warehouseNameController,
                  label: "Warehouse Name",
                  hintText: "e.g. Karachi Hub",
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Cancel",
                        color: Colors.grey[200],
                        textColor: Colors.black,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Obx(
                        () => CustomButton(
                          text: "Create",
                          isLoading: getXController.isLoading.value,
                          onPressed: () => getXController.createWarehouse(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget warehousesContainer() {
    return RefreshIndicator(
      onRefresh: () async {
        await getXController.fetchWarehouses();
      },
      color: AppColors.blackColor,
      child: Obx(() {
        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: getXController.warehouses.length,
          itemBuilder: (context, index) {
            final warehouse = getXController.warehouses[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: InkWell(
                onTap: () async {
                  GetAppStorage.getWarehouseID_Data(warehouse.id);
                  GetAppStorage.saveWarehouseName(warehouse.name);
                  // yeh pagecontroller or controllers ko delete krdeta hai purne wale
                  await Get.delete<BottomNavigationContoller>(force: true);
                  // Jab user naviagte karega kisi bhi warehouse may toh usko us specific warehouse ka data show hoga.
                  await Get.delete<DashboardController>(force: true);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.bottomNavigationScreen,
                    (route) => false,
                  );
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  height: 90.h,
                  padding: EdgeInsets.all(15.r),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: warehouse.name ?? "N/A",
                        color: AppColors.blackColor,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4.h),
                      CustomText(
                        text: 'JOINED: ${warehouse.formattedDate}',
                        color: Colors.grey.shade500,
                        fontSize: 12.sp,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
