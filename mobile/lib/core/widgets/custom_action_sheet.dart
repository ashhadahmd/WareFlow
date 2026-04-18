import 'package:flutter/material.dart';
import 'package:get/get.dart'; // RxBool ke liye zaroori hai
import 'package:warehouse_management_system/core/constants/app_colors.dart';
import 'package:warehouse_management_system/core/widgets/custom_button.dart';
import 'package:warehouse_management_system/core/widgets/custom_text.dart';

class CustomActionSheet {
  static void show({
    required BuildContext context,
    required String title,
    required VoidCallback onUpdate,
    required VoidCallback onDelete,
    required RxBool isLoading, // 👈 Yahan RxBool pass karo
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ActionSheetContent(
        title: title,
        onUpdate: onUpdate,
        onDelete: onDelete,
        isLoading: isLoading, // 👈 Content ko aage pass karo
      ),
    );
  }
}

class ActionSheetContent extends StatelessWidget {
  final String title;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final RxBool isLoading; // 👈 Naya variable

  const ActionSheetContent({
    super.key,
    required this.title,
    required this.onUpdate,
    required this.onDelete,
    required this.isLoading, // 👈 Constructor mein maango
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          CustomText(
            text: title,
            color: AppColors.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const CustomText(
              text: "Update",
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Navigator.pop(context);
              onUpdate();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const CustomText(
              text: "Delete",
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
            onTap: () {
              Navigator.pop(context);
              _showConfirmDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    // ❌ GHATIA LOGIC REMOVED: final getXController = Get.find<AddProductController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const CustomText(
          text: "Confirm Delete",
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        content: CustomText(
          text: "Are you sure you want to delete '$title'?",
          color: Colors.grey,
        ),
        actions: [
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: "Cancel",
                    color: Colors.grey[200],
                    textColor: Colors.black,
                    // Jab loading ho toh cancel button disable kardo
                    onPressed: isLoading.value
                        ? () {}
                        : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: "Delete",
                    color: AppColors.redColor,
                    isLoading: isLoading.value, // ✅ AB DIRECT RXBOOL USE HOGA
                    onPressed: isLoading.value ? () {} : onDelete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
