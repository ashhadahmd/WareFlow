import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color color;
  final FontWeight? fontWeight;
  final double? fontSize;
  final TextAlign? textAlign;
  const CustomText({
    super.key,
    required this.text,
    required this.color,
    this.fontWeight,
    this.fontSize,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: color,
        fontWeight: fontWeight,
        fontSize: fontSize,
      ),
      textAlign: textAlign,
    );
  }
}
