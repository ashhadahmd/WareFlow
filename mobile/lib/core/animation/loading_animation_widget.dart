import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';

class LoadingAnimation extends StatelessWidget {
  final Color? loadingColor;
  const LoadingAnimation({this.loadingColor = Colors.transparent, super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.waveDots(
      color: loadingColor ?? AppColors.blackColor,
      size: 30.r,
    );
  }
}
