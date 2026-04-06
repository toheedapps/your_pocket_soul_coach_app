import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoSection extends StatelessWidget {
  const AppLogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.tertiary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/logo/soul_logo.png',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
        ),
        SizedBox(height: 3.h),

        // Header
        Text(
          'Your Pocket Soul Coach',
          style: GoogleFonts.inter(
            fontSize: 23.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 1.h),

        // Subheader
        Text(
          'A sanctuary for your mental, emotional, and spiritual well-being.',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.15,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),

        // Body Text (added for Welcome Screen)
        // Text(
        //   'Welcome home.\nThis is your safe space to breathe, heal, reflect, and grow — one conversation at a time.',
        //   style: GoogleFonts.inter(
        //     fontSize: 14.sp,
        //     fontWeight: FontWeight.w400,
        //     color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        //     height: 1.5,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
      ],
    );
  }
}