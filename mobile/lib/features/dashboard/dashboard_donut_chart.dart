import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/dashboard/dashboard_controller.dart';

class DashboardDonutChart extends StatelessWidget {
  final DashboardController getXController = Get.put(DashboardController());
  DashboardDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    Color categoryColor(String categoryName) {
      switch (categoryName.trim().toLowerCase()) {
        case 'technology':
          return Colors.grey.shade700;
        case 'storage':
          return const Color(0xFF1A1C1E);
        case 'equipment':
          return Colors.grey.shade500;
        case 'packaging':
          return Colors.grey.shade300;
        case 'safety':
          return Colors.grey.shade200;
        default:
          return Colors.red;
      }
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      height: 230.h,
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5.r,
            spreadRadius: 1.r,
            offset: Offset(0.w, 0.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Inventory by Category",
            color: AppColors.blackColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 15.h),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Chart Section (Left)
                SizedBox(
                  height: 140.h,
                  width: 140.w,
                  child: Obx(() {
                    // FIX: Animation tab trigger hogi jab hum empty state handle karenge
                    final isDataEmpty =
                        getXController.dountChartlist.isEmpty ||
                        getXController.dountChartValue.value == 0;

                    final sections = isDataEmpty
                        ? [
                            PieChartSectionData(
                              value: 1,
                              color: Colors.transparent,
                              radius: 18.r,
                              showTitle: false,
                            ),
                          ]
                        : getXController.dountChartlist.map((item) {
                            // FIX: Added safety for division by zero
                            final total = getXController.dountChartValue.value;
                            final percentage = total > 0
                                ? (item.value / total) * 100
                                : 0.0;
                            return PieChartSectionData(
                              value: percentage,
                              color: categoryColor(item.category),
                              radius: 18.r,
                              showTitle: false,
                            );
                          }).toList();

                    return PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 50.r,
                        startDegreeOffset: -90, // Animation starts from top
                        sections: sections,
                      ),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOutQuart,
                    );
                  }),
                ),

                // 2. Legend Section (Right)
                Flexible(
                  child: SingleChildScrollView(
                    child: Obx(
                      () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: getXController.dountChartlist.map((item) {
                          final total = getXController.dountChartValue.value;
                          final percentage = total > 0
                              ? (item.value / total) * 100
                              : 0.0;
                          return _buildLegendItem(
                            item.category,
                            percentage.toStringAsFixed(0),
                            categoryColor(item.category),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15.r,
            height: 15.r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: CustomText(
              text: title,
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(width: 6.w),
          CustomText(
            text: '$value%',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ],
      ),
    );
  }
}
