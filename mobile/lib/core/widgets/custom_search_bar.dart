import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: onChanged,
          controller: controller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: AppColors.blackColor),
            hintText: 'Search by name or SKU...',
            hintStyle: const TextStyle(
              color: AppColors.greyColor,
              fontSize: 14,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 10,
            ),
          ),
        ),
      ),
    );
  }
}
