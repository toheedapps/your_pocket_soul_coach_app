import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data
class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Bar - NOW AUTO-HIGHLIGHTS + AUTO-NAVIGATES
class CustomBottomBar extends StatelessWidget {
  final int currentIndex; // -1 = auto-detect from route
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    this.currentIndex = -1, // ← AUTO MODE DEFAULT
    this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home-dashboard',
    ),
    BottomNavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Coach',
      route: '/ai-coaching-chat',
    ),
    BottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/subscription-management',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // ←← AUTO-DETECT INDEX FROM CURRENT ROUTE
    int effectiveIndex = currentIndex;
    if (currentIndex == -1) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      effectiveIndex = _navItems.indexWhere((item) => item.route == currentRoute);
      effectiveIndex = effectiveIndex == -1 ? 0 : effectiveIndex; // fallback Home
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
                  (index) => _buildNavItem(
                context,
                _navItems[index],
                index,
                effectiveIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context,
      BottomNavItem item,
      int index,
      bool isSelected,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color itemColor = isSelected
        ? (selectedItemColor ?? colorScheme.primary)
        : (unselectedItemColor ?? colorScheme.onSurfaceVariant.withOpacity(0.6));

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: colorScheme.primary.withOpacity(0.12),
          highlightColor: colorScheme.primary.withOpacity(0.08),
          onTap: () => _handleTap(context, index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // ← FIXED TYPO
              children: [
                Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  color: itemColor,
                  size: 28,
                ),
                if (showLabels) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: itemColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();

    // Parent override? Use it. Else auto-navigate
    if (onTap != null) {
      onTap!(index);
    } else {
      final route = _navItems[index].route;
      if (ModalRoute.of(context)?.settings.name != route) {
        Navigator.pushReplacementNamed(context, route);
      }
    }
  }

  // ←← BACKWARD COMPATIBLE FACTORIES (keep your old CustomBottomBar.chat() etc)
//   static Widget chat() => const CustomBottomBar(currentIndex: 1); // Coach
//   static Widget home() => const CustomBottomBar(currentIndex: 0);  // Home
//   static Widget profile() => const CustomBottomBar(currentIndex: 2); // Profile
}