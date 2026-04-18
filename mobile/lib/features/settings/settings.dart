import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_container.dart';
import 'package:warehouse_management_system/core/widgets/custom_general_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/bottom_navigation/bottom_navi_controller.dart';
import 'package:warehouse_management_system/features/dashboard/dashboard_controller.dart';
import 'package:warehouse_management_system/features/start_screen/auth_controller/auth_controller.dart';
import 'package:warehouse_management_system/features/start_screen/select_warehouse/select_warehouse.dart';

class Settings extends StatelessWidget {
  final DashboardController getXController = Get.put(DashboardController());
  final AuthController getXauthController = Get.put(AuthController());
  Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.transparentColor,
        title: CustomText(
          text: 'Settings',
          color: AppColors.blackColor,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Column(
            children: [
              CustomContainer(
                height: 100.h,
                widget: customWorkSpace(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomText(
                            text: 'WORKSPACE',
                            color: AppColors.greyColor,
                            fontSize: 20.r,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            text: getXController.warehouseName,
                            color: AppColors.blackColor,
                            fontSize: 18.r,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      Icon(LucideIcons.warehouse, color: AppColors.greyColor),
                    ],
                  ),
                ),
              ),
              //
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  text: 'General',
                  fontSize: 18.r,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyColor,
                ),
              ),
              SizedBox(height: 5.h),
              //
              CustomGeneralButton(
                text: 'Switch Warehouse',
                textColor: AppColors.blackColor,
                tralingIcon: LucideIcons.arrowLeftCircle,
                onTap: () async {
                  await Get.delete<BottomNavigationContoller>(force: true);
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType
                          .leftToRight, // Professional animation
                      child: const SelectWarehouse(),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                tralingIconColor: AppColors.blackColor,
              ),
              Obx(
                () => CustomGeneralButton(
                  text: 'Logout',
                  textColor: AppColors.whiteColor,
                  containerColor: AppColors.blackColor,
                  tralingIcon: LucideIcons.logOut,
                  tralingIconColor: AppColors.whiteColor,
                  isLoading: getXauthController.isLoading.value,
                  loadingColor: AppColors.whiteColor,
                  onTap: () => getXauthController.logOut(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget customWorkSpace(Widget widget) {
  return Container(
    padding: EdgeInsets.all(15.r),
    decoration: BoxDecoration(
      color: AppColors.transparentColor,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: AppColors.borderGrey, // Stroke ka color
        width: 1.w, // Stroke ki thickness
      ),
    ),
    child: widget,
  );
}
