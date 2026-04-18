import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_app_bar.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          text: 'Orders',
          buttonText: '+ Create Order',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.createOrderScreen);
          },
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(children: []),
    );
  }
}
