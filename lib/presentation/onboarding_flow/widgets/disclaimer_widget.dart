import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DisclaimerWidget extends StatefulWidget {
  final String text;
  final ValueChanged<bool> onAcceptedChanged;  // Callback for checkbox

  const DisclaimerWidget({
    super.key,
    required this.text,
    required this.onAcceptedChanged,
  });

  @override
  State<DisclaimerWidget> createState() => _DisclaimerWidgetState();
}

class _DisclaimerWidgetState extends State<DisclaimerWidget> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: colorScheme.primary,
                size: 28,
              ),
              SizedBox(width: 3.w),
              Text(
                'Important Disclaimer'.toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Scrollable Text
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Checkbox
          GestureDetector(
            onTap: () {
              setState(() => _isAccepted = !_isAccepted);
              widget.onAcceptedChanged(_isAccepted);
            },
            child: Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (value) {
                    setState(() => _isAccepted = value ?? false);
                    widget.onAcceptedChanged(_isAccepted);
                  },
                  activeColor: colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    'I have read and understand this disclaimer',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}