import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_getx_message.dart';
import 'package:warehouse_management_system/core/widgets/custom_text_field.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/start_screen/auth_controller/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Get.find behtar hai agar AuthController pehle hi Login mein put ho chuka hai
  final AuthController getXcontroller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          bottom: true,
          top: false,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  // Fixed height (500) hata di taake content ke mutabiq resize ho
                  padding: EdgeInsets.symmetric(
                    vertical: 25.h,
                    horizontal: 15.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10.r,
                        spreadRadius: 2.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'WAREFLOW',
                        color: AppColors.blackColor,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                      ),
                      SizedBox(height: 5.h),
                      CustomText(
                        text: 'Create an account',
                        color: Colors.grey,
                        fontSize: 16.sp,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: getXcontroller.nameController,
                        label: 'Name',
                        hintText: 'Enter your full name',
                      ),
                      CustomTextField(
                        controller: getXcontroller.emailController,
                        label: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      Obx(
                        () => CustomTextField(
                          controller: getXcontroller.passwordController,
                          label: 'Password',
                          hintText: 'Create a password',
                          obscureText: getXcontroller
                              .isPasswordHidden
                              .value, // Password hide hona chahiye
                          suffixIcon: getXcontroller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onPressed: () {
                            getXcontroller.togglePasswordVisibility();
                          },
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Obx(
                        () => CustomButton(
                          width: double.infinity,
                          text: 'Register',
                          isLoading: getXcontroller.isLoading.value,
                          onPressed: () async {
                            bool isSuccess = await getXcontroller.signUp();
                            if (!mounted) return;
                            if (isSuccess) {
                              // Agar signup success hai toh login par bhej do
                              getXcontroller.clearFields();
                              Get.offNamed(AppRoutes.loginScreen);
                              GetXMessage.onSuccess(
                                message:
                                    "Account has been created successfully!",
                              );
                            } else {
                              Get.snackbar(
                                "Error",
                                "SignUp failed.",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "Already have an account? ",
                            color: Colors.grey,
                            fontSize: 13.sp,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: CustomText(
                              text: 'Sign in',
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
