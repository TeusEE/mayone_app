import 'package:flutter/material.dart';

import 'package:mayone_app/theme/app_theme.dart';

/// 아직 개발 중인 기능 자리표시 화면.
class TempWidget extends StatelessWidget {
  const TempWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 56, color: AppColors.tan),
          SizedBox(height: 16),
          Text(
            '준비 중인 기능이에요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.coffee,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'To Be Developed',
            style: TextStyle(color: AppColors.muted, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
