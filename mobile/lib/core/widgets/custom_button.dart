import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/animation/loading_animation_widget.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';

class CustomNavButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const CustomNavButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blackColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: CustomText(text: text, color: AppColors.whiteColor),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;
  final Color? loadingColor;
  final Color? textColor;
  final double? height;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.loadingColor,
    this.height,
    this.width,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 52,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.blackColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? LoadingAnimation(loadingColor: loadingColor)
            : CustomText(
                text: text,
                color: textColor ?? AppColors.whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
      ),
    );
  }
}
