import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/model/supplier_model/supplier_model.dart'; // Apna model path sahi karo
import 'package:warehouse_management_system/core/widgets/custom_text.dart';
import 'package:warehouse_management_system/core/widgets/info_display_row.dart';

class ShowSupplier extends StatelessWidget {
  const ShowSupplier({super.key});

  @override
  Widget build(BuildContext context) {
    // Receiving data from SupplierTile screen
    final supplier =
        ModalRoute.of(context)!.settings.arguments as SupplierModel;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        surfaceTintColor: AppColors.transparentColor,
        title: CustomText(
          text: 'Supplier Detail',
          color: AppColors.blackColor,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Icon Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.business_center_outlined, // Supplier relevant icon
                    size: 60,
                    color: AppColors.blueColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Name and Contact Header
            Center(
              child: Column(
                children: [
                  CustomText(
                    text: supplier.name ?? "No Name",
                    color: AppColors.blackColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 5),
                  CustomText(
                    text: "Contact: ${supplier.contactName ?? 'N/A'}",
                    color: Colors.grey[600]!,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Supplier Information Rows
            InfoDisplayRow(label: "Status", value: supplier.status ?? "N/A"),
            InfoDisplayRow(
              label: "Rating",
              value: "${supplier.rating ?? 0} Stars",
            ),
            InfoDisplayRow(
              label: "Email",
              value: supplier.email ?? "Not Provided",
            ),
            InfoDisplayRow(
              label: "Phone",
              value: supplier.phone != null ? supplier.phone.toString() : "N/A",
            ),
            InfoDisplayRow(
              label: "Address",
              value: supplier.address ?? "No Address Set",
            ),

            InfoDisplayRow(label: "System ID", value: "#${supplier.id ?? 0}"),
            InfoDisplayRow(
              label: "Warehouse ID",
              value: "#${supplier.warehouseId ?? 0}",
            ),
          ],
        ),
      ),
    );
  }
}
