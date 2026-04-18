import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/model/inventory_model/inventory_model.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/core/widgets/info_display_row.dart';

class ShowInventory extends StatelessWidget {
  const ShowInventory({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Safe way to receive arguments
    final args = ModalRoute.of(context)?.settings.arguments;

    // Agar data nahi mila toh screen khali dikhane ke bajaye error handling karo
    if (args == null || args is! InventoryModel) {
      return const Scaffold(body: Center(child: Text("Invalid Product Data")));
    }

    final product = args;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          text: 'Product Details',
          color: AppColors.blackColor,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Icon Card (Responsive height)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 50.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 80.r,
                color: Colors.blueAccent,
              ),
            ),

            SizedBox(height: 20.h),

            // Name & SKU Section
            Center(
              child: Column(
                children: [
                  CustomText(
                    text: product.name ?? "Unknown Product",
                    color: Colors.black,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 5.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: CustomText(
                      text: "SKU: ${product.sku ?? 'N/A'}",
                      color: Colors.blue.shade700,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h),

            // Details Group
            _buildSectionTitle("General Information"),
            InfoDisplayRow(
              label: "Category",
              value: product.category ?? "General",
            ),
            InfoDisplayRow(label: "Price", value: "Rs. ${product.price ?? 0}"),

            SizedBox(height: 20.h),

            _buildSectionTitle("Inventory Status"),
            InfoDisplayRow(
              label: "Current Stock",
              value: "${product.quantity ?? 0}",
              // Yahan logic add kar sakte ho: agar stock < minStock toh color red dikhao
            ),
            InfoDisplayRow(
              label: "Min. Threshold",
              value: "${product.minStock ?? 0}",
            ),
            InfoDisplayRow(
              label: "Location",
              value: product.location ?? "Not Assigned",
            ),

            SizedBox(height: 20.h),

            _buildSectionTitle("System Info"),
            InfoDisplayRow(
              label: "Warehouse ID",
              value: "#${product.warehouseId ?? 0}",
            ),
            InfoDisplayRow(
              label: "Supplier ID",
              value: "#${product.supplierId ?? 0}",
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  // Helper widget for clean organization
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 5.w),
      child: CustomText(
        text: title,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}
