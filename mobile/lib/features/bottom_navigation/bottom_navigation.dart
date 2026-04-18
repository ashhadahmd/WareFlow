import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/features/bottom_navigation/bottom_navi_controller.dart';
import 'package:warehouse_management_system/features/dashboard/dashboard.dart';
import 'package:warehouse_management_system/features/settings/settings.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  final BottomNavigationContoller getXController = Get.put(
    BottomNavigationContoller(),
  );

  final List<Widget> _screens = [
    Dashboard(),
    // Inventory(),
    // Orders(), // Will make it one by one
    // Suppliers(),
    Settings(),
  ];

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.layoutDashboard),
      label: "Dashboard",
    ),
    // BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventory"),
    // BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Orders"),
    // BottomNavigationBarItem(icon: Icon(Icons.people), label: "Suppliers"),
    BottomNavigationBarItem(
      icon: Icon(LucideIcons.settings),
      label: "Settings",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: getXController.pageController,
        children: _screens,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: getXController.currentIndex.value,
          onTap: (index) {
            getXController.onChangedPage(index);
          },
          type: BottomNavigationBarType.fixed,
          // .r icons ke liye scale handle karta hai
          iconSize: 22.r,
          selectedItemColor: AppColors.blackColor,
          // .sp text scaling ke liye
          selectedFontSize: 11.sp,
          unselectedItemColor: AppColors.greyColor,
          unselectedFontSize: 11.sp,
          items: items,
        ),
      ),
    );
  }
}
