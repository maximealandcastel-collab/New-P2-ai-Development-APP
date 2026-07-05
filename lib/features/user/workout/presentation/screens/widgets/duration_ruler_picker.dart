import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DurationRulerPicker extends StatefulWidget {
  final int min;
  final int max;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const DurationRulerPicker({
    super.key,
    this.min = 1,
    this.max = 120,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<DurationRulerPicker> createState() => _DurationRulerPickerState();
}

class _DurationRulerPickerState extends State<DurationRulerPicker> {
  late ScrollController _scrollController;
  late int _selectedValue;
  late double _tickSpacing;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue.clamp(widget.min, widget.max);
    _tickSpacing = 12.w;
    final initialOffset = (_selectedValue - widget.min) * _tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final value =
        widget.min + (_scrollController.offset / _tickSpacing).round();
    final clamped = value.clamp(widget.min, widget.max);
    if (clamped != _selectedValue) {
      setState(() => _selectedValue = clamped);
      widget.onChanged(clamped);
    }
  }

  void _snapToSelected() {
    final targetOffset = (_selectedValue - widget.min) * _tickSpacing;
    if ((_scrollController.offset - targetOffset).abs() > 0.5) {
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.max - widget.min + 1;
    final halfWidth = MediaQuery.of(context).size.width / 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: '$_selectedValue',
          fontSize: 40.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        CustomText(
          text: 'min',
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 40.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    _snapToSelected();
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: halfWidth),
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    final value = widget.min + index;
                    final isMajor = value % 5 == 0;
                    return SizedBox(
                      width: _tickSpacing,
                      child: Center(
                        child: Container(
                          width: 1.5.w,
                          height: isMajor ? 44.h : 24.h,
                          color: AppColors.colorE6E6E6,
                        ),
                      ),
                    );
                  },
                ),
              ),
              IgnorePointer(
                child: Container(
                  width: 2.w,
                  height: 26.h,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}