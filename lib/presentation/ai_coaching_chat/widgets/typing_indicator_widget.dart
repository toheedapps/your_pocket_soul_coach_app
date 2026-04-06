import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final bool isVisible;
  final String coachImageUrl;

  const TypingIndicatorWidget({
    super.key,
    required this.isVisible,
    required this.coachImageUrl,
  });

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.isVisible) _animationController.repeat();
  }

  @override
  void didUpdateWidget(TypingIndicatorWidget old) {
    super.didUpdateWidget(old);
    if (widget.isVisible && !old.isVisible) {
      _animationController.repeat();
    } else if (!widget.isVisible && old.isVisible) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final String image = widget.coachImageUrl.isNotEmpty
        ? widget.coachImageUrl
        : 'assets/coach/default_coach.jpg';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              key: ValueKey(widget.coachImageUrl),  // ← THIS LINE IS THE MAGIC
              child: CustomImageWidget(
                imageUrl: widget.coachImageUrl,
                width: 8.w,
                height: 8.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _buildDot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final progress = (_animation.value + index * 0.2) % 1.0;
        final opacity = progress < 0.5 ? progress * 2 : 2 - progress * 2;
        return Container(
          margin: EdgeInsets.only(left: index == 0 ? 0 : 1.w),
          width: 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3 + opacity * 0.7),
          ),
        );
      },
    );
  }
}