import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final Color? color;
  final GestureTapCallback? onPressed;

  const CustomIcon({
    super.key,
    this.icon,
    this.size,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: color),
    );
  }
}
