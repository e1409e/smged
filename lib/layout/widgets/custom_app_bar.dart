// lib/layout/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:smged/layout/widgets/custom_TextStyles.dart';
import 'package:smged/layout/widgets/custom_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;


  const CustomAppBar({
    super.key,
    required this.title,

  });


  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyles.title,
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textTitle,
      actions: const [], 
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}