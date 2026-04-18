import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:warehouse_management_system/core/animation/loading_animation_widget.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_container.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';

class CustomGeneralButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String text;
  final Color textColor;
  final Color? containerColor;
  final Color? loadingColor;
  final IconData tralingIcon;
  final Color tralingIconColor;
  final bool isLoading;
  const CustomGeneralButton({
    required this.text,
    required this.textColor,
    required this.tralingIcon,
    required this.onTap,
    required this.tralingIconColor,
    this.containerColor,
    this.loadingColor,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 7.h),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: CustomContainer(
          buttonBorderRadius: 12.r,
          color: containerColor ?? AppColors.whiteColor,
          widget: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: isLoading
                ? Center(child: LoadingAnimation(loadingColor: loadingColor))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: text,
                        fontSize: 18.r,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      Icon(tralingIcon, color: tralingIconColor),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
