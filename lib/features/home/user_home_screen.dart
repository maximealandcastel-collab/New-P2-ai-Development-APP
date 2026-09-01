import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/image_path.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';
import 'package:pler_to_pler_app/features/user/achievements/presentation/achievements_screen.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/user/rate_my_peel/presentation/rate_my_peel_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_find/presentation/workout_find_screen.dart';
import 'package:pler_to_pler_app/widgets/app_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// User Home — matches design:
// greeting bar → Daily workout progress (week strip) → Gyms near you →
// Generate Workout Split banner → Rate My Peel → Today's overview
// ─────────────────────────────────────────────────────────────────────────────

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _calendarKey = GlobalKey<_DailyWorkoutCalendarState>();

  Future<void> _refreshHome() async {
    _calendarKey.currentState?.resetToToday();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF6B35),
          onRefresh: _refreshHome,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeedAppBar(),
                const _AchievementsPill(),
                SizedBox(height: 8.h),
                _DailyWorkoutCalendar(key: _calendarKey),
                SizedBox(height: 16.h),
                const _GymsCard(),
                SizedBox(height: 16.h),
                const _GenerateWorkoutBanner(),
                SizedBox(height: 16.h),
                const _RateMyPeelBanner(),
                SizedBox(height: 16.h),
                _SectionTitle("Today's overview"),
                const _TodaysOverviewCard(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementsPill extends StatelessWidget {
  const _AchievementsPill();

  static const _gold = Color(0xFFD2A23A);
  static const _goldSoft = Color(0xFFFFF4D9);
  static const _ink = Color(0xFF171717);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          button: true,
          label: 'Open your achievements',
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: _goldSoft,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: _gold.withOpacity(0.18)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18.r),
                splashColor: _gold.withOpacity(0.12),
                highlightColor: _gold.withOpacity(0.06),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                ),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: _gold,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Achievements',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 21.w,
                        height: 21.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: _gold,
                          size: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ─── Daily workout progress calendar ─────────────────────────────────────────
class _DailyWorkoutCalendar extends StatefulWidget {
  const _DailyWorkoutCalendar({super.key});

  @override
  State<_DailyWorkoutCalendar> createState() => _DailyWorkoutCalendarState();
}

class _DailyWorkoutCalendarState extends State<_DailyWorkoutCalendar> {
  static const _orange = Color(0xFFFF6B35);
  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF777777);
  static const _line = Color(0xFFE9E9E9);

  late DateTime _weekStart;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _weekStart = _mondayOf(today);
    _selectedDate = today;
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _mondayOf(DateTime date) {
    final cleanDate = _dateOnly(date);
    return cleanDate.subtract(Duration(days: cleanDate.weekday - DateTime.monday));
  }

  static bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _monthName(DateTime date) => _months[date.month - 1];

  String _weekLabel() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
    if (_weekStart.year == weekEnd.year && _weekStart.month == weekEnd.month) {
      return '${_monthName(_weekStart)} ${_weekStart.day}–${weekEnd.day}, ${weekEnd.year}';
    }
    if (_weekStart.year == weekEnd.year) {
      return '${_monthName(_weekStart)} ${_weekStart.day} – '
          '${_monthName(weekEnd)} ${weekEnd.day}, ${weekEnd.year}';
    }
    return '${_monthName(_weekStart)} ${_weekStart.day}, ${_weekStart.year} – '
        '${_monthName(weekEnd)} ${weekEnd.day}, ${weekEnd.year}';
  }

  void _changeWeek(int amount) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: amount * 7));
      final selectedWeekday = _selectedDate.weekday - DateTime.monday;
      _selectedDate = _weekStart.add(Duration(days: selectedWeekday));
    });
  }

  void _goToToday() {
    final today = _dateOnly(DateTime.now());
    setState(() {
      _weekStart = _mondayOf(today);
      _selectedDate = today;
    });
  }

  void resetToToday() => _goToToday();

  _WorkoutDayProgress _progressFor(DateTime date) {
    // This remains a single source of truth for the calendar UI. When the
    // dashboard workout activity feed is connected, this method can map the
    // persisted completion count without changing the calendar presentation.
    return const _WorkoutDayProgress(completed: 0, total: 10);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily workout progress',
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                        letterSpacing: -0.25,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Track and manage your clients’ workouts',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _CalendarIconButton(
                icon: Icons.chevron_left_rounded,
                label: 'Previous week',
                onTap: () => _changeWeek(-1),
              ),
              SizedBox(width: 6.w),
              _CalendarIconButton(
                icon: Icons.chevron_right_rounded,
                label: 'Next week',
                onTap: () => _changeWeek(1),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                _weekLabel(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: 'Return to today',
                child: InkWell(
                  onTap: _goToToday,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _isSameDate(_selectedDate, today)
                          ? const Color(0xFFFFF1EC)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: _isSameDate(_selectedDate, today)
                            ? _orange.withOpacity(0.35)
                            : _line,
                      ),
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _isSameDate(_selectedDate, today)
                            ? _orange
                            : _ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final compactCardWidth = ((constraints.maxWidth - (6 * 6.w)) / 7)
                  .clamp(44.w, 68.w)
                  .toDouble();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.none,
                child: Row(
                  children: List.generate(7, (index) {
                    final date = _weekStart.add(Duration(days: index));
                    return Padding(
                      padding: EdgeInsets.only(right: index == 6 ? 0 : 6.w),
                      child: _CalendarDayCard(
                        date: date,
                        isToday: _isSameDate(date, today),
                        isSelected: _isSameDate(date, _selectedDate),
                        progress: _progressFor(date),
                        width: compactCardWidth,
                        monthName: _monthName(date),
                        onTap: () => setState(() => _selectedDate = date),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: _orange.withOpacity(0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    size: 15.sp,
                    color: _orange,
                  ),
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: Text(
                    _isSameDate(_selectedDate, today)
                        ? 'Today’s workout progress'
                        : '${_selectedDate.day} ${_monthName(_selectedDate)} progress',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: _ink,
                    ),
                  ),
                ),
                Text(
                  '${_progressFor(_selectedDate).completed}/'
                  '${_progressFor(_selectedDate).total}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CalendarIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.r),
        child: Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: const Color(0xFFE9E9E9)),
          ),
          child: Icon(
            icon,
            size: 19.sp,
            color: const Color(0xFF202020),
          ),
        ),
      ),
    );
  }
}

class _CalendarDayCard extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final _WorkoutDayProgress progress;
  final double width;
  final String monthName;
  final VoidCallback onTap;

  const _CalendarDayCard({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.progress,
    required this.width,
    required this.monthName,
    required this.onTap,
  });

  static const _orange = Color(0xFFFF6B35);

  static const _weekdayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedColor = isSelected ? _orange : const Color(0xFF202020);
    final backgroundColor =
        isSelected ? const Color(0xFFFFF8F5) : Colors.white;

    return Semantics(
      button: true,
      selected: isSelected,
      label:
          '${_weekdayLabels[date.weekday - 1]} ${date.day} $monthName, '
          '${progress.completed} of ${progress.total} exercises complete',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: width,
          constraints: BoxConstraints(minHeight: 132.h),
          padding: EdgeInsets.fromLTRB(5.w, 11.h, 5.w, 8.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? _orange.withOpacity(0.62)
                  : const Color(0xFFE9E9E9),
              width: isSelected ? 1.35 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _orange.withOpacity(0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _weekdayLabels[date.weekday - 1],
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 9.2.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.25,
                  color: isSelected || isToday
                      ? _orange
                      : const Color(0xFF7A7A7A),
                ),
              ),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 23.sp,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                  color: selectedColor,
                ),
              ),
              Text(
                monthName.substring(0, 3).toUpperCase(),
                style: TextStyle(
                  fontSize: 9.2.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF888888),
                ),
              ),
              _ProgressPill(progress: progress, isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  final _WorkoutDayProgress progress;
  final bool isSelected;

  const _ProgressPill({
    required this.progress,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isPerfect = progress.completed == progress.total && progress.total > 0;
    final statusColor = progress.statusColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(isSelected ? 0.14 : 0.09),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPerfect ? Icons.fitness_center_rounded : Icons.circle,
            size: isPerfect ? 11.sp : 6.sp,
            color: statusColor,
          ),
          SizedBox(width: 3.w),
          Flexible(
            child: Text(
              '${progress.completed}/${progress.total}',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutDayProgress {
  final int completed;
  final int total;

  const _WorkoutDayProgress({
    required this.completed,
    required this.total,
  });

  Color get statusColor {
    if (completed >= total && total > 0) return const Color(0xFF38A169);
    if (completed == 0) return const Color(0xFFA3A3A3);
    if (completed < total / 2) return const Color(0xFFF2B531);
    return const Color(0xFFFF6B35);
  }
}

// ─── Gyms near you ───────────────────────────────────────────────────────────
class _GymsCard extends StatelessWidget {
  const _GymsCard();

  @override
  Widget build(BuildContext context) {
    final gyms = EnterpriseGymModel.partners.take(3).toList();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gyms',
                  style: TextStyle(
                       fontSize: 14.sp,
                       fontWeight: FontWeight.w400,
                      color: Colors.black)),
              Semantics(
                button: true,
                label: 'Open nearby gyms',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final controller = BottomNavBarController.to;
                    final gymsIndex = controller.indexOfTab(NavItemId.gyms);
                    if (gymsIndex >= 0) {
                      controller.onChange(gymsIndex);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: Text('Near Gym',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFFF6B35))),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 155.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
               itemCount: gyms.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                 final gym = gyms[i];
                return SizedBox(
                  width: 142.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       GymStockImage(
                         gym: gym,
                         height: 75.h,
                         width: double.infinity,
                         borderRadius: 12.r,
                       ),
                      SizedBox(height: 5.h),
                       Text(gym.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                               fontSize: 11.5.sp,
                               fontWeight: FontWeight.w400,
                               letterSpacing: 0.05,
                              color: Colors.black)),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12.sp, color: Colors.black54),
                          SizedBox(width: 2.w),
                           Text(
                               gym.distanceLabel.isEmpty
                                   ? gym.city
                                   : gym.distanceLabel,
                              style: TextStyle(
                                   fontSize: 10.sp,
                                   fontWeight: FontWeight.w400,
                                   color: Colors.black45)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                       Text(
                         gym.isActivated ? 'Active gym' : 'Coming soon',
                         style: TextStyle(
                           fontSize: 9.5.sp,
                           fontWeight: FontWeight.w400,
                           color: gym.isActivated
                               ? const Color(0xFF2E7D32)
                               : Colors.black38,
                         ),
                       ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generate Workout Split banner ───────────────────────────────────────────
class _GenerateWorkoutBanner extends StatelessWidget {
  const _GenerateWorkoutBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WorkoutFinderFlow()),
      ),
      child: Semantics(
        button: true,
        label: 'Generate workout split',
        child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: AspectRatio(
            aspectRatio: 1696 / 927,
            child: Image.asset(
              ImagePath.generateWorkoutSplit,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ─── Rate My Peel teaser ──────────────────────────────────────────────────────
class _RateMyPeelBanner extends StatelessWidget {
  const _RateMyPeelBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Rate My Peel. Coming soon.',
      hint: 'Opens the Rate My Peel feature overview',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RateMyPeelScreen()),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              height: 132.h,
              child: Image.asset(
                ImagePath.rateMyPeelBanner,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) =>
                    const _RateMyPeelAssetFallback(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RateMyPeelAssetFallback extends StatelessWidget {
  const _RateMyPeelAssetFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101010),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFFFF6B35),
            size: 22,
          ),
          SizedBox(width: 10),
          Text(
            'Rate My Peel  ·  COMING SOON',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Today's overview card ────────────────────────────────────────────────────
class _TodaysOverviewCard extends StatelessWidget {
  const _TodaysOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: CustomPaint(
              painter: _CircleProgressPainter(progress: 0.0),
              child: Center(
                child: Text(
                  '0%',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverviewRow(
                  color: const Color(0xFFFFAB4C),
                  icon: Icons.track_changes,
                  label: 'Goal',
                  value: 'Maintain Physique',
                ),
                SizedBox(height: 12.h),
                _OverviewRow(
                  color: const Color(0xFF5B9BD5),
                  icon: Icons.accessibility_new,
                  label: 'Focus Area',
                  value: 'Full Body',
                ),
                SizedBox(height: 12.h),
                _OverviewRow(
                  color: const Color(0xFF72C472),
                  icon: Icons.bolt,
                  label: 'Intensity',
                  value: 'Medium',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  const _OverviewRow(
      {required this.color,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10.5.sp,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400)),
            Text(value,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  const _CircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final bgPaint = Paint()
      ..color = const Color(0xFFEDEDED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final fgPaint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter old) => old.progress != progress;
}
