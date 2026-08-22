import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import 'input_decoration.dart';

class SignUpForm extends StatefulWidget {
  final Function(String name, String email, String password)? onSignUp;
  final bool isLoading;

  const SignUpForm({
    super.key,
    this.onSignUp,
    this.isLoading = false,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter your full name';
    }
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter your email address';
    }
    if (!_isValidEmail(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _handleSignUp() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the Mental Health Disclaimer and Terms to continue.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w400),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    widget.onSignUp?.call(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'MENTAL HEALTH DISCLAIMER',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Your Soul Pocket Coach is a supportive wellness tool. '
                'It is not a replacement for therapy or emergency mental health care. '
                'If you are in danger or need immediate help, please contact local emergency services or a mental health professional.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Text (added for consistency with Sign In)
          Text(
            'Welcome, Beautiful Soul',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // Name Field
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            scrollPadding: EdgeInsets.only(bottom: 24.h),
            validator: _validateName,
            decoration: authFieldDecoration(
              label: 'Full Name',
              hint: 'Full Name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            scrollPadding: EdgeInsets.only(bottom: 24.h),
            validator: _validateEmail,
            decoration: authFieldDecoration(
              label: 'Email Address',
              hint: 'Email Address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'mail_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            scrollPadding: EdgeInsets.only(bottom: 24.h),
            validator: _validatePassword,
            decoration: authFieldDecoration(
              label: 'Password',
              hint: 'Password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                icon: CustomIconWidget(
                  iconName: _isPasswordVisible ? 'visibility' : 'visibility_off',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            scrollPadding: EdgeInsets.only(bottom: 24.h),
            validator: _validateConfirmPassword,
            onFieldSubmitted: (_) => _handleSignUp(),
            decoration: authFieldDecoration(
              label: 'Confirm Password',
              hint: 'Confirm Password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                icon: CustomIconWidget(
                  iconName: _isConfirmPasswordVisible ? 'visibility' : 'visibility_off',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Terms and Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _acceptTerms = !_acceptTerms;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(text: 'I accept the '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _showTermsDialog,
                              child: Text(
                                'Mental Health Disclaimer and Terms.',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color:
                                  AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 7.h,
            child: ElevatedButton(
              onPressed: !widget.isLoading ? _handleSignUp : null,
              child: widget.isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              )
                  : Text(
                'Begin Your Healing Journey',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}