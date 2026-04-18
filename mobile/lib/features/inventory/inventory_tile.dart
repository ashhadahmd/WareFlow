import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Added for responsiveness
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/model/inventory_model/inventory_model.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_action_sheet.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/product_features/product_controller.dart';

class InventoryTile extends StatelessWidget {
  final InventoryModel product;
  const InventoryTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final AddProductController getXController = Get.put(AddProductController());

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ), // Screen width ke hisab se constant padding
      child: InkWell(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ActionSheetContent(
              isLoading: getXController.isLoading,
              title: product.name!,
              onUpdate: () {
                getXController.initialData(product);

                Navigator.pushNamed(
                  context,
                  AppRoutes.updateProductScreen,
                  arguments: product,
                );
              },
              onDelete: () => getXController.deleteProduct(product.id!),
            ),
          );
        },
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.showInventoryScreen,
            arguments: product,
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h), // Spacing between tiles
          padding: EdgeInsets.all(16.r), // Internal padding for content
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(15.r), // Smooth corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // === Image Picker: Add in Future (Commented remains unchanged) ===
              /*
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: AppColors.greyColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.blackColor,
                  size: 30.r,
                ),
              ),
              SizedBox(width: 15.w),
              */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomText(
                            text: product.name ?? 'NA',
                            color: AppColors.blackColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        CustomText(
                          text: 'Qty: ${product.quantity}',
                          color: AppColors.blackColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),

                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'SKU: ${product.sku ?? 'NA'}',
                                color: AppColors.greyColor,
                                fontSize: 13.sp,
                              ),
                              SizedBox(height: 2.h),
                              CustomText(
                                text: 'Loc: ${product.location ?? 'Unknown'}',
                                color: AppColors.greyColor,
                                fontSize: 13.sp,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: CustomText(
                            text: 'In Stock',
                            color: AppColors.greenColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
