import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginSection extends StatelessWidget {
  final VoidCallback? onGoogleSignIn;
  final bool isLoading;

  const SocialLoginSection({
    super.key,
    this.onGoogleSignIn,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        // Row(
        //   children: [
        //     Expanded(
        //       child: Divider(
        //         color: AppTheme.lightTheme.colorScheme.outline
        //             .withValues(alpha: 0.3),
        //         thickness: 1,
        //       ),
        //     ),
        //     Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 2.w),
        //       child: Text(
        //         'OR',
        //         style: GoogleFonts.inter(
        //           fontSize: 14.sp,
        //           fontWeight: FontWeight.w500,
        //           color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        //           letterSpacing: 0.5,
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: Divider(
        //         color: AppTheme.lightTheme.colorScheme.outline
        //             .withValues(alpha: 0.3),
        //         thickness: 1,
        //       ),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 2.h),

        // Social Login Buttons
        Column(
          children: [
            // Google Sign In Button
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  HapticFeedback.lightImpact();
                  _showConsentDialog(context, 'Google', onGoogleSignIn);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageWidget(
                      imageUrl:
                      'https://developers.google.com/identity/images/g-logo.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Continue with Google',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ],
    );
  }

  void _showConsentDialog(
      BuildContext context, String provider, VoidCallback? onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Wellness Data Consent',  // Updated for tone
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By signing in with $provider, you consent to:',  // Kept, warm
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              _buildConsentItem('Secure storage of your wellness data'),
              _buildConsentItem('AI-powered coaching interactions'),
              _buildConsentItem('Mood tracking and progress monitoring'),
              _buildConsentItem('Crisis detection and support resources'),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'security',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Your privacy is protected. Data is encrypted and never shared without consent.',  // Kept, aligns with tone
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.lightTheme.colorScheme.primary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: Text(
              'I Consent',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildConsentItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 16,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}