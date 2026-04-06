import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isUser;
  final String coachImageUrl;  // ← ADD THIS
  final VoidCallback? onLongPress;
  final VoidCallback? onReply;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.coachImageUrl,  // ← ADD THIS
    required this.isUser,
    this.onLongPress,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              _buildCoachAvatar(context),
              SizedBox(width: 2.w),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 75.w),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isUser ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['content'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTimestamp(message['timestamp'] as DateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUser
                                ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                : colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                        if (isUser) ...[
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: _getStatusIcon(),
                            color: colorScheme.onPrimary.withValues(alpha: 0.7),
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              SizedBox(width: 2.w),
              _buildUserAvatar(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoachAvatar(BuildContext context) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: CustomImageWidget(
          imageUrl: coachImageUrl,  // ← NOW USES THE PASSED URL
          width: 8.w,
          height: 8.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      ),
      child: CustomIconWidget(
        iconName: 'person',
        color: Theme.of(context).colorScheme.primary,
        size: 16,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  String _getStatusIcon() {
    final status = message['status'] as String? ?? 'sent';
    switch (status) {
      case 'sending':
        return 'schedule';
      case 'sent':
        return 'check';
      case 'delivered':
        return 'done_all';
      case 'read':
        return 'done_all';
      default:
        return 'check';
    }
  }
}
