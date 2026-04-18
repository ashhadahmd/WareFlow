import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_app_bar.dart';
import 'package:warehouse_management_system/core/widgets/custom_search_bar.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/product_features/product_controller.dart';
import 'package:warehouse_management_system/features/inventory/inventory_tile.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  // Get.find tab use karein agar controller splash ya dashboard par put ho chuka hai
  final AddProductController getXcontroller = Get.put(AddProductController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: CustomAppBar(
            text: 'Inventory',
            buttonText: '+ Add Product',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.addProductScreen),
          ),
        ),
        body: Column(
          children: [
            // Search Bar area responsive padding ke sath
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: CustomSearchBar(
                controller: getXcontroller.searchController,
                onChanged: (value) => getXcontroller.searchProduct(value),
              ),
            ),

            SizedBox(height: 5.h),

            // Main Content
            Expanded(
              child: Obx(() {
                // 1. Loading State (Agar backend se data aa raha hai)
                if (getXcontroller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Empty State (Agar search result khali ho)
                if (getXcontroller.foundProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 50.r,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10.h),
                        CustomText(
                          text: "No products found",
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ],
                    ),
                  );
                }

                // 3. Data List
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 20.h), // End par thora gap
                  physics: const BouncingScrollPhysics(),
                  itemCount: getXcontroller.foundProducts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 4.h,
                      ),
                      child: InventoryTile(
                        product: getXcontroller.foundProducts[index],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
