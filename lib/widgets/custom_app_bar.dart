import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Therapeutic Minimalism design
/// for mental wellness application with trust-building visual elements
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title text displayed in the app bar
  final String title;

  /// Whether to show the back button (defaults to true when there's a previous route)
  final bool showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show elevation shadow (defaults to false for therapeutic minimalism)
  final bool showElevation;

  /// Background color override (uses theme color if not provided)
  final Color? backgroundColor;

  /// Text color override (uses theme color if not provided)
  final Color? foregroundColor;

  /// Whether to center the title (defaults to true)
  final bool centerTitle;

  /// Custom bottom widget (for tabs, progress indicators, etc.)
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.leading,
    this.actions,
    this.showElevation = false,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if we should show back button
    final bool canPop = Navigator.of(context).canPop();
    final bool shouldShowBackButton =
        showBackButton && canPop && leading == null;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: showElevation ? 2.0 : 0,
      shadowColor: showElevation ? colorScheme.shadow : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
      leading:
      leading ?? (shouldShowBackButton ? _buildBackButton(context) : null),
      automaticallyImplyLeading: shouldShowBackButton,
      actions: actions != null
          ? [
        ...actions!,
        const SizedBox(width: 8), // Padding for actions
      ]
          : null,
      bottom: bottom,
      iconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: foregroundColor ?? colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  /// Builds a custom back button with therapeutic design
  Widget _buildBackButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () {
        // Provide haptic feedback for reassuring physical confirmation
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: foregroundColor ?? colorScheme.onSurface,
        size: 20,
      ),
      tooltip: 'Back',
      splashRadius: 24,
      padding: const EdgeInsets.all(12),
    );
  }

  /// Factory constructor for home dashboard app bar
  factory CustomAppBar.home({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Mindful Moments',
      showBackButton: false,
      actions: actions ??
          [
            Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/subscription-management');
                },
                icon: const Icon(Icons.person_outline_rounded),
                tooltip: 'Profile',
              ),
            ),
          ],
    );
  }

  /// Factory constructor for chat interface app bar
  // factory CustomAppBar.chat({
  //   Key? key,
  //   String coachName = 'AI Coach',
  //   VoidCallback? onInfoTap,
  // }) {
  //   return CustomAppBar(
  //     key: key,
  //     title: coachName,
  //     actions: [
  //       Builder(
  //         builder: (context) => IconButton(
  //           onPressed: () {
  //             HapticFeedback.lightImpact();
  //             onInfoTap?.call();
  //           },
  //           icon: const Icon(Icons.info_outline_rounded),
  //           tooltip: 'Coach Info',
  //         ),
  //       ),
  //     ],
  //   );
  // }

  /// Factory constructor for authentication screens
  factory CustomAppBar.auth({
    Key? key,
    String title = 'Welcome',
  }) {
    return CustomAppBar(
      key: key,
      title: title,
      showBackButton: true,
    );
  }

  /// Factory constructor for subscription management
  factory CustomAppBar.subscription({
    Key? key,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Subscription',
      // actions: [
      //   Builder(
      //     builder: (context) => IconButton(
      //       onPressed: () {
      //         HapticFeedback.lightImpact();
      //         // Show help or support options
      //         // _showHelpBottomSheet(context);
      //       },
      //       // icon: const Icon(Icons.help_outline_rounded),
      //       // tooltip: 'Help',
      //     ),
      //   ),
      // ],
    );
  }

  /// Shows help bottom sheet for subscription support
  // static void _showHelpBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).colorScheme.surface,
  //         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  //       ),
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Handle bar
  //           Center(
  //             child: Container(
  //               width: 40,
  //               height: 4,
  //               decoration: BoxDecoration(
  //                 color: Theme.of(context).colorScheme.outline,
  //                 borderRadius: BorderRadius.circular(2),
  //               ),
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //
  //           Text(
  //             'Need Help?',
  //             style: GoogleFonts.inter(
  //               fontSize: 24,
  //               fontWeight: FontWeight.w600,
  //               color: Theme.of(context).colorScheme.onSurface,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //
  //           Text(
  //             'We\'re here to support your wellness journey. Contact us for any subscription questions or technical support.',
  //             style: GoogleFonts.inter(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w400,
  //               color: Theme.of(context).colorScheme.onSurfaceVariant,
  //               height: 1.5,
  //             ),
  //           ),
  //           const SizedBox(height: 24),
  //
  //           // Help options
  //           _buildHelpOption(
  //             context,
  //             icon: Icons.email_outlined,
  //             title: 'Email Support',
  //             subtitle: 'Get help via email',
  //             onTap: () {
  //               // Handle email support
  //               Navigator.pop(context);
  //             },
  //           ),
  //           const SizedBox(height: 12),
  //
  //           _buildHelpOption(
  //             context,
  //             icon: Icons.chat_bubble_outline,
  //             title: 'Live Chat',
  //             subtitle: 'Chat with our support team',
  //             onTap: () {
  //               // Handle live chat
  //               Navigator.pop(context);
  //             },
  //           ),
  //
  //           const SizedBox(height: 24),
  //
  //           // Close button
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Close'),
  //             ),
  //           ),
  //
  //           // Safe area padding
  //           SizedBox(height: MediaQuery.of(context).padding.bottom),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Builds a help option tile
  static Widget _buildHelpOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}
