import 'package:flutter/material.dart';

import 'app_theme.dart';

class TextFieldContainer extends StatelessWidget {
  final bool? isObscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  const TextFieldContainer({
    Key? key,
    this.hintText,
    this.prefixIcon,
    this.isObscureText,
    this.keyboardType,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1F2A44), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        obscureText: isObscureText == true,
        keyboardType: keyboardType ?? TextInputType.text,
        controller: controller,
        style: AppText.body,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon ?? Icons.circle, color: AppColors.textSecondary),
          hintText: hintText,
          hintStyle: AppText.secondary,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
