import 'package:flutter/material.dart';

// --- Legacy palette (still used by the old auth/settings screens) ---
const careysPink = Color(0xFFC89FA9);
const roseFog = Color(0xFFECDCDC);
const rockBlue = Color(0xFF9DABCB);
const bermudaGray = Color(0xFF7284A6);
const rhino = Color(0xFF334564);

// --- New design system (from the app mockups) ---
class AppColors {
  static const primary = Color(0xFF6C7BD6); // periwinkle/indigo
  static const primaryDark = Color(0xFF1F2A44); // navy headings
  static const textSecondary = Color(0xFF8A94A8); // muted grey
  static const background = Color(0xFFEEF1F7); // app background
  static const surface = Color(0xFFFFFFFF); // cards
  static const stroke = Color(0xFFE3E8F1);

  static const success = Color(0xFF2E9E5B);
  static const successBg = Color(0xFFDCF3E4);
  static const warning = Color(0xFFC98A16);
  static const warningBg = Color(0xFFFBECD2);
  static const neutralBg = Color(0xFFEDEFF4);

  static const placeholder = Color(0xFFE7ECF6);
  static const placeholderStripe = Color(0xFFDBE2F0);
  static const placeholderLabel = Color(0xFF9FAAC6);
}

class AppText {
  static const heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
  );
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );
  static const body = TextStyle(
    fontSize: 15,
    color: AppColors.primaryDark,
    height: 1.4,
  );
  static const secondary = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
