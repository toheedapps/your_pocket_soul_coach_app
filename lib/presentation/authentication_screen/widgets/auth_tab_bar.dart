import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AuthTabBar extends StatelessWidget {
  final TabController tabController;
  final Function(int) onTabChanged;

  const AuthTabBar({
    super.key,
    required this.tabController,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TabBar(
        controller: tabController,
        onTap: onTabChanged,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        labelStyle: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            text: 'Sign In',
            height: 48,
          ),
          Tab(
            text: 'Sign Up',  // Updated from 'Sign Up'
            height: 48,
          ),
        ],
      ),
    );
  }
}