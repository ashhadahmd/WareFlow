import 'package:flutter/material.dart';
import 'package:warehouse_management_system/core/widgets/custom_icon.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;
  final double? suffixIconSize;
  final Color? suffixIconColor;
  final GestureTapCallback? onPressed;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.obscureText,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.suffixIcon,
    this.suffixIconColor,
    this.suffixIconSize,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: TextFormField(
        obscureText: obscureText ?? false,
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        textInputAction: textInputAction,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[100],
          //
          suffixIcon: CustomIcon(
            icon: suffixIcon,
            size: suffixIconSize,
            color: suffixIconColor,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
