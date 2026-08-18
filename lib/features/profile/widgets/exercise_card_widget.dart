import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ExerciseCardWidget extends StatelessWidget {
  const ExerciseCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 12.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      paddingVertical: 6.h,
      child: ListTile(
        leading: CustomNetworkImage(
          borderRadius: 8.r,
          width: 48.w,
          height: 54.h,
          imageUrl: 'https://picsum.photos/300',),

        contentPadding: EdgeInsets.zero,
        title: CustomText(
          textAlign: TextAlign.start,
          fontWeight: FontWeight.w600,
          text: '20 upper body exercise',
          maxline: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: '15 minutes 8 Exercise step',
        ),
        trailing: IconButton(onPressed: (){}, icon: Icon(Icons.more_vert,color: AppColors.textPrimary,)),
      ),
    );
  }
}



