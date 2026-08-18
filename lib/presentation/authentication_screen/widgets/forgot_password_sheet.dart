import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:yspc/services/firebase_auth_service.dart';
import 'package:yspc/services/firestore_service.dart';
import '../../../core/app_export.dart';
import 'input_decoration.dart';

class ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;
  final VoidCallback? onNavigateToSignUp;

  const ForgotPasswordSheet({
    super.key,
    this.initialEmail = '',
    this.onNavigateToSignUp,
  });

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _authService = FirebaseAuthService();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isNotRegistered = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleSendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isNotRegistered = false;
    });

    final email = _emailController.text.trim();

    try {
      // Send Password Reset Email directly via Firebase Auth
      await _authService.sendPasswordResetEmail(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        HapticFeedback.mediumImpact();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.code == 'user-not-found') {
            _isNotRegistered = true;
            _errorMessage = 'This email is not registered. Please register first.';
          } else {
            _errorMessage = _mapFirebaseAuthError(e);
          }
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred: $e';
        });
      }
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'This email is not registered. Please register first.';
      case 'invalid-email':
        return 'The email address is not formatted correctly.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes before trying again.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection.';
      default:
        return e.message ?? 'Failed to send reset link. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final primaryColor = AppTheme.lightTheme.colorScheme.primary;
    final textColor = AppTheme.lightTheme.colorScheme.onSurface;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: _isSuccess
              ? _buildSuccessView(primaryColor, textColor)
              : _buildFormView(primaryColor, textColor),
        ),
      ),
    );
  }

  Widget _buildFormView(Color primaryColor, Color textColor) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 2.5.h),

          // Header Row with Icon & Title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: CustomIconWidget(
                  iconName: 'lock_reset',
                  color: primaryColor,
                  size: 26,
                ),
              ),
              SizedBox(width: 3.5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forgot Password',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Enter your email to receive a reset link',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.grey.shade500,
                  size: 22,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),

          // Error / Not Registered Banner
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
              decoration: BoxDecoration(
                color: _isNotRegistered
                    ? Colors.amber.shade50
                    : AppTheme.lightTheme.colorScheme.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isNotRegistered
                      ? Colors.amber.shade300
                      : AppTheme.lightTheme.colorScheme.error.withOpacity(0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isNotRegistered ? Icons.warning_amber_rounded : Icons.error_outline_rounded,
                        color: _isNotRegistered
                            ? Colors.amber.shade800
                            : AppTheme.lightTheme.colorScheme.error,
                        size: 22,
                      ),
                      SizedBox(width: 2.5.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: _isNotRegistered
                                ? Colors.amber.shade900
                                : AppTheme.lightTheme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isNotRegistered && widget.onNavigateToSignUp != null) ...[
                    SizedBox(height: 1.2.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          widget.onNavigateToSignUp?.call();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                        label: Text(
                          'Register Now',
                          style: GoogleFonts.inter(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Email Input Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: widget.initialEmail.isEmpty,
            validator: _validateEmail,
            onFieldSubmitted: (_) => _handleSendResetLink(),
            style: GoogleFonts.inter(fontSize: 14.sp, color: textColor),
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                  _isNotRegistered = false;
                });
              }
            },
            decoration: authFieldDecoration(
              label: 'Email Address',
              hint: 'Enter your registered email',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'mail_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: _emailController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _emailController.clear();
                        setState(() {
                          _errorMessage = null;
                          _isNotRegistered = false;
                        });
                      },
                      icon: CustomIconWidget(
                        iconName: 'cancel',
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 3.h),

          // Send Reset Link Button
          SizedBox(
            width: double.infinity,
            height: 6.8.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Send Reset Link',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 1.5.h),

          // Cancel / Back to Login
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Remember your password? Sign In',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(Color primaryColor, Color textColor) {
    final email = _emailController.text.trim();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 1.h),
        // Success Checkmark Badge
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.successLight.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: const BoxDecoration(
              color: AppTheme.successLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        SizedBox(height: 2.5.h),

        // Title
        Text(
          'Password Reset Sent!',
          style: GoogleFonts.inter(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 1.2.h),

        // Body message
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'We sent a secure password reset link to\n'),
                TextSpan(
                  text: email,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const TextSpan(
                  text: '.\n\n⚠️ Note: If you do not see it in 1-2 minutes, please check your ',
                ),
                TextSpan(
                  text: 'Spam / Junk folder',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        SizedBox(height: 3.5.h),

        // Back to Sign In Button
        SizedBox(
          width: double.infinity,
          height: 6.8.h,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Back to Sign In',
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),

        // Resend option
        TextButton(
          onPressed: () {
            setState(() {
              _isSuccess = false;
            });
          },
          child: Text(
            'Didn’t receive the email? Try again',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
