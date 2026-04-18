import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/model/supplier_model/supplier_model.dart';
import 'package:warehouse_management_system/core/routes/app_routes.dart';
import 'package:warehouse_management_system/core/widgets/custom_action_sheet.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/features/supplier_features/supplier_controller.dart';

class SupplierTile extends StatelessWidget {
  final SupplierModel supplier;
  const SupplierTile({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final SupplierController getXcontroller = Get.put(SupplierController());
    final double screenSize = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize * 0.027),
      child: InkWell(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ActionSheetContent(
              isLoading: getXcontroller.isLoading,
              title: supplier.name!,
              onUpdate: () {
                getXcontroller.initialData(supplier);
                Navigator.pushNamed(
                  context,
                  AppRoutes.updateSupplierScreen,
                  arguments: supplier,
                );
              },
              onDelete: () => getXcontroller.deleteSupplier(supplier.id!),
            ),
          );
        },
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.showSupplierScreen,
            arguments: supplier,
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: screenSize * 0.04),
          padding: EdgeInsets.all(screenSize * 0.044),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(screenSize * 0.041),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === 1. Header Row (Name & Status) ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomText(
                      text: supplier.name ?? 'Company Name NA',
                      color: AppColors.blackColor,
                      fontSize: screenSize * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Active Status Badge (Missing in your variables)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize * 0.025,
                      vertical: screenSize * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(screenSize * 0.02),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: screenSize * 0.015,
                          height: screenSize * 0.015,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: screenSize * 0.015),
                        CustomText(
                          text: 'active',
                          color: Colors.green,
                          fontSize: screenSize * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize * 0.02),

              // === 2. Contact Name ===
              CustomText(
                text: supplier.contactName ?? 'Contact Name NA',
                color: AppColors.greyColor,
                fontSize: screenSize * 0.038,
              ),

              Divider(
                color: Colors.grey.withValues(alpha: 0.2),
                height: screenSize * 0.06,
              ),

              // === 3. Contact Info (Email, Phone, Address) ===
              _buildInfoRow(
                Icons.email_outlined,
                supplier.email ?? 'No Email',
                screenSize,
              ),
              SizedBox(height: screenSize * 0.02),
              _buildInfoRow(
                Icons.phone_outlined,
                supplier.phone.toString(),
                screenSize,
              ),
              SizedBox(height: screenSize * 0.02),
              _buildInfoRow(
                Icons.location_on_outlined,
                supplier.address.toString(),
                screenSize,
              ),

              Divider(
                color: Colors.grey.withValues(alpha: 0.2),
                height: screenSize * 0.06,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatColumn('Products', '15', screenSize),
                  _buildStatColumn('Orders', '48', screenSize),
                  _buildRatingColumn('Rating', '4.8', screenSize),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build info rows (Email, Phone, Location) cleanly
  Widget _buildInfoRow(IconData icon, String text, double screenSize) {
    return Row(
      children: [
        Icon(icon, size: screenSize * 0.04, color: Colors.grey.shade600),
        SizedBox(width: screenSize * 0.02),
        Expanded(
          child: CustomText(
            text: text,
            color: Colors.grey.shade600,
            fontSize: screenSize * 0.035,
          ),
        ),
      ],
    );
  }

  // Helper function for Products & Orders stats
  Widget _buildStatColumn(String label, String value, double screenSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: label,
          color: Colors.grey.shade500,
          fontSize: screenSize * 0.03,
        ),
        SizedBox(height: screenSize * 0.01),
        CustomText(
          text: value,
          color: AppColors.blackColor,
          fontSize: screenSize * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  // Helper function exclusively for Rating to include the Star icon
  Widget _buildRatingColumn(String label, String value, double screenSize) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.end, // Align to right like the image
      children: [
        CustomText(
          text: label,
          color: Colors.grey.shade500,
          fontSize: screenSize * 0.03,
        ),
        SizedBox(height: screenSize * 0.01),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: screenSize * 0.045),
            SizedBox(width: screenSize * 0.01),
            CustomText(
              text: value,
              color: Colors.black,
              fontSize: screenSize * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }
}
