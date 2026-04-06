import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Retry connection widget for network timeout scenarios
class RetryConnectionWidget extends StatelessWidget {
  /// Callback when retry button is tapped
  final VoidCallback? onRetry;

  /// Error message to display
  final String errorMessage;

  /// Whether to show the retry widget
  final bool isVisible;

  const RetryConnectionWidget({
    super.key,
    this.onRetry,
    this.errorMessage =
    'Connection Timeout. Please Check Your Internet Connection.',
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color:
              AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'wifi_off',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 8.w,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Error message
          Text(
            errorMessage,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),

          // Retry button
          SizedBox(
            width: 40.w,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onRetry?.call();
              },
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 4.w,
              ),
              label: Text(
                'Try Again',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
