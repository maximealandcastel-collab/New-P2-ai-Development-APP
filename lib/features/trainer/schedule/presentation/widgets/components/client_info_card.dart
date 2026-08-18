import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Client Info Card Component
/// Displays client details with call and message actions
class ClientInfoCard extends StatelessWidget {
  final String clientName;
  final String clientId;
  final String? clientImageUrl;
  final bool isOnline;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;

  const ClientInfoCard({
    super.key,
    required this.clientName,
    required this.clientId,
    this.clientImageUrl,
    this.isOnline = true,
    this.onCall,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Client info row
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundImage: clientImageUrl != null
                    ? NetworkImage(clientImageUrl!)
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: clientImageUrl == null
                    ? Icon(Icons.person, size: 22.r, color: Colors.grey.shade400)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'ID: $clientId',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOnline) _ClientOnlineBadge(),
            ],
          ),
          SizedBox(height: 14.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  icon: Icons.videocam_outlined,
                  label: 'Call',
                  onTap: onCall,
                  isOutlined: true,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  onTap: onMessage,
                  isOutlined: false,
                  primaryColor: const Color(0xFFFF7A00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientOnlineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.w,
            height: 5.h,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Online',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action Button Component
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isOutlined;
  final Color? primaryColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isOutlined = true,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white : (primaryColor ?? const Color(0xFFFF7A00)),
          borderRadius: BorderRadius.circular(10.r),
          border: isOutlined ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isOutlined ? Colors.black87 : Colors.white,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isOutlined ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
