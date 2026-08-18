import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/domain/repositories/schedule_repository.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/bindings/schedule_binding.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/controllers/schedule_controller.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/client_info_card.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/empty_schedule.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/schedule_summary_card.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/schedule_timeline_section.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/session_card.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/session_info_card.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/session_info_header.dart';
import 'package:pler_to_pler_app/features/trainer/schedule/presentation/widgets/components/trainer_app_bar.dart';

/// Main Schedule Screen
/// Refactored using Clean Architecture and component-based UI
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register schedule dependencies if not already registered
    if (!Get.isRegistered<ScheduleRepository>()) {
      ScheduleBinding().dependencies();
    }
    return GetBuilder<ScheduleController>(
      init: ScheduleController(
        repository: Get.find<ScheduleRepository>(),
      ),
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              TrainerAppBar(
                userName: 'Maxime',
                profileImageUrl: 'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200',
                isOnline: true,
                notificationCount: 5,
              ),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.sessions.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // Schedule Summary
                        ScheduleSummaryCard(
                          sessionToday: controller.selectedDayIndex.value == 3
                              ? controller.summary.value?.sessionToday ?? 5
                              : 0,
                          needAttention: controller.selectedDayIndex.value == 3
                              ? controller.summary.value?.needAttention ?? 4
                              : 0,
                        ),

                        SizedBox(height: 16.h),

                        // Schedule Timeline
                        ScheduleTimelineSection(
                          dayLabels: controller.dayLabels,
                          dayNumbers: controller.dayNumbers,
                          hasDot: controller.hasDot,
                          selectedIndex: controller.selectedDayIndex.value,
                          showCalendar: controller.showCalendar.value,
                          selectedCalDay: controller.selectedCalendarDay.value,
                          onDaySelected: controller.selectDay,
                          onToggleCalendar: controller.toggleCalendarView,
                          onCalDaySelected: controller.selectCalendarDay,
                        ),

                        SizedBox(height: 12.h),

                        // Sessions List or Empty State
                        if (!controller.hasSessions)
                          const EmptySchedule()
                        else
                          ...controller.sessions.map(
                            (session) => SessionCard(
                              session: session,
                              onTap: () => Get.to(() => const SessionDetailsScreen()),
                              onStartCall: () => controller.startCallSession(session.id),
                              onMessage: () => controller.sendMessageToClient(
                                session.clientId,
                                'Hello!',
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Session Details Screen
/// Displays detailed information about a specific session
class SessionDetailsScreen extends StatelessWidget {
  const SessionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            _buildAppBar(context),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session Info Header
                    const SessionInfoHeader(
                      title: 'Virtual physical therapy\nsession.',
                      dateLabel: 'Tomorrow',
                      time: '06:30 PM',
                      sessionTag: 'Rehab session',
                    ),

                    SizedBox(height: 18.h),

                    // Session Note
                    const SessionInfoCard(
                      title: 'Session note',
                      content:
                          'A live, one-on-one virtual session focused on assessing movement, reducing pain, and supporting recovery. The therapist reviews progress, guides personalized exercises, and adjusts the treatment plan to improve mobility and function conveniently from home.',
                    ),

                    SizedBox(height: 14.h),

                    // Session ID
                    const SessionIdCard(sessionId: '#150-250-5420'),

                    SizedBox(height: 18.h),

                    // Client Section
                    Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Client Info Card
                    ClientInfoCard(
                      clientName: 'Ethan Rodriguez',
                      clientId: '321-654-9870',
                      clientImageUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                      isOnline: true,
                      onCall: () {},
                      onMessage: () {},
                    ),

                    SizedBox(height: 24.h),

                    // Cancel Button
                    GestureDetector(
                      onTap: () {
                        Get.dialog(_buildCancelDialog(context));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel Schedule',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // Reschedule Button
                    GestureDetector(
                      onTap: () {
                        Get.snackbar('Info', 'Reschedule functionality coming soon');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Reschedule Session',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                size: 20.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Session details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }

  Widget _buildCancelDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Session'),
      content: const Text('Are you sure you want to cancel this session?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            Get.snackbar('Success', 'Session cancelled');
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Yes, Cancel'),
        ),
      ],
    );
  }
}
