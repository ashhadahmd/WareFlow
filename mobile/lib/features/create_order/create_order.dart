import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';

class CreateOrder extends StatelessWidget {
  const CreateOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: CustomText(
          text: 'Create Order',
          color: AppColors.blackColor,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: []),
    );
  }
}
