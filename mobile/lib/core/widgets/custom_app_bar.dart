import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';

class CustomAppBar extends StatelessWidget {
  final String text;
  final String buttonText;
  final VoidCallback onTap;
  const CustomAppBar({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.transparentColor,
      scrolledUnderElevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: text,
            color: AppColors.blackColor,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
          CustomNavButton(text: buttonText, onTap: onTap),
        ],
      ),
    );
  }
}
