import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GetXMessage {
  // 1. SUCCESS METHOD (Top Alert)
  static void onSuccess({
    String title = 'Success', // Default title
    required String message,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP, // Top positioning
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      leftBarIndicatorColor: Colors.green, // Fixed color
      icon: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 28.r,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15.r,
          offset: const Offset(0, 5), // Shadow drops down
        ),
      ],
      animationDuration: const Duration(milliseconds: 800),
      forwardAnimationCurve: Curves.fastOutSlowIn,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  // 2. ERROR METHOD (Bottom Alert)
  static void onError({
    String title = 'Error', // Default title
    required String message,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP, // Bottom positioning
      // Bottom ke liye bottom navigation bar ke hisaab se thori extra space zaroori hai
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 25.h),
      backgroundColor: Colors.white,
      colorText: Colors.black87,
      leftBarIndicatorColor: Colors.redAccent, // Fixed color
      icon: Padding(
        padding: EdgeInsets.only(left: 10.w),
        child: Icon(Icons.error_outline, color: Colors.redAccent, size: 28.r),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15.r,
          offset: const Offset(0, -5), // Shadow goes UP (Senior detail)
        ),
      ],
      animationDuration: const Duration(milliseconds: 800),
      forwardAnimationCurve: Curves.fastOutSlowIn,
      reverseAnimationCurve: Curves.easeInBack,
      // Error message parhne mein zyada time lagta hai isliye 4 seconds diye hain
      duration: const Duration(seconds: 4),
    );
  }
}
