import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text_field.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/start_screen/auth_controller/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController getXcontroller = Get.put(AuthController());

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
              // SingleChildScrollView keyboard overflow se bachata hai
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  // Height ko 430 se badal kar responsive kiya
                  padding: EdgeInsets.symmetric(
                    vertical: 30.h,
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
                    mainAxisSize: MainAxisSize
                        .min, // Container content ke mutabiq adjust hoga
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'WAREFLOW',
                        color: AppColors.blackColor,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: 'Welcome back',
                        color: Colors.grey,
                        fontSize: 16.sp,
                      ),
                      SizedBox(height: 15.h),
                      CustomTextField(
                        controller: getXcontroller.emailController,
                        label: 'Email',
                        hintText: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: Icons.email_outlined,
                      ),
                      Obx(
                        () => CustomTextField(
                          controller: getXcontroller.passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
                          obscureText: getXcontroller.isPasswordHidden.value,
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
                          width: double
                              .infinity, // Button ko container ki full width di hai
                          text: 'Login',
                          isLoading: getXcontroller.isLoading.value,
                          onPressed: () async {
                            await getXcontroller.login();
                            if (!mounted) return;
                            if (getXcontroller.loginUserToken != null) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.selectWarehouseScreen,
                                (route) =>
                                    false, // Ye 'offAll' ka kaam karega (pichli history clear)
                                arguments: getXcontroller.loginUserToken,
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
                            text: "Don't have an account? ",
                            color: Colors.grey,
                            fontSize: 13.sp,
                          ),
                          GestureDetector(
                            onTap: () {
                              getXcontroller.clearFields();
                              Navigator.pushNamed(
                                context,
                                AppRoutes.signUpScreen,
                              );
                            },
                            child: CustomText(
                              text: 'Sign up',
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
