import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';

class InfoDisplayRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoDisplayRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: label,
                color: AppColors.greyColor.withValues(alpha: 2),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              CustomText(
                text: value,
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
        Divider(
          color: AppColors.greyColor.withValues(alpha: 0.2),
          thickness: 1,
        ),
      ],
    );
  }
}
