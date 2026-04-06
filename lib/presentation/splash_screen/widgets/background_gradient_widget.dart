import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Background gradient widget with therapeutic colors for splash screen
class BackgroundGradientWidget extends StatelessWidget {
  /// Whether to use dark theme colors
  final bool isDarkMode;

  const BackgroundGradientWidget({
    super.key,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [
            AppTheme.darkTheme.scaffoldBackgroundColor,
            AppTheme.darkTheme.colorScheme.surface,
            AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.1),
          ]
              : [
            AppTheme.lightTheme.scaffoldBackgroundColor,
            AppTheme.lightTheme.colorScheme.surface,
            AppTheme.lightTheme.colorScheme.primary
                .withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              isDarkMode
                  ? AppTheme.darkTheme.colorScheme.tertiary
                  .withValues(alpha: 0.03)
                  : AppTheme.lightTheme.colorScheme.tertiary
                  .withValues(alpha: 0.02),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
      ),
    );
  }
}
