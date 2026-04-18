import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';

class CustomContainer extends StatelessWidget {
  final Widget widget;
  final double? height;
  final Color? color;
  final double? buttonBorderRadius;
  const CustomContainer({
    super.key,
    required this.widget,
    this.height,
    this.buttonBorderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 60.h,
      width: double.infinity,
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color ?? AppColors.whiteColor,
        borderRadius: BorderRadius.circular(buttonBorderRadius ?? 20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5.r,
            spreadRadius: 1.r,
            offset: Offset(0.w, 0.h),
          ),
        ],
      ),
      child: widget,
    );
  }
}
