
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:smged/layout/widgets/custom_colors.dart';

class TextStyles{
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF5F3F3),
  );
  static const TextStyle titleTables = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0F0F0F),
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xB3FFFFFF),
  );
  static const TextStyle label = TextStyle(
    color: Color(0xFF757575), 
  );
  static const TextStyle labelfocus = TextStyle(
    color: AppColors.primary, 
  );
  static const TextStyle error = TextStyle(
    fontSize: 18,
    color: AppColors.error,
  );
}