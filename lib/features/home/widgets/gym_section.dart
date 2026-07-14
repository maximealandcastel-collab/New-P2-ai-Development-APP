import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';

class GymSection extends StatelessWidget {
  const GymSection({super.key});

  Future<void> _openNearGymMap() async {
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=gyms+near+me");
    final Uri appleMapsUrl = Uri.parse("https://maps.apple.com/?q=gyms+near+me");

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
          return;
        }
      }
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        ToastMessageHelper.show('Could not open map application.');
      }
    } catch (e) {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        ToastMessageHelper.show('Could not open maps: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return         CustomContainer(
      marginTop: 8.h,
      color: Colors.white,
      radiusAll: 16.r,
      paddingVertical: 14.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(child: CustomText(
                  textAlign: TextAlign.start,
                  text: 'Gyms',fontWeight: FontWeight.w600,)),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _openNearGymMap,
                  child: CustomText(
                      textAlign: TextAlign.start,
                      text: 'Near Gym',fontWeight: FontWeight.w600,color: AppColors.primary),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),
          CustomContainer(
            height: 134.h,
            paddingVertical: 4.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              separatorBuilder: (_, __) =>  SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16.w : 0,
                    right: index == 9 ? 16.w : 0,
                  ),
                  child: CustomContainer(
                    radiusAll: 12.r,
                    bordersColor: AppColors.secondary,
                    width: 110.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10.r)
                          ),
                          child: CustomNetworkImage(
                            imageUrl: '',
                            height: 62.h,
                            width: double.infinity,
                          ),
                        ),
                        CustomText(
                            top: 4.h,
                            left: 4.w,
                            right: 4.w,
                            maxline: 1,
                            textOverflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                            text: 'StrongFit Downtown',fontSize: 12.sp,fontWeight: FontWeight.w600),

                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 4.w,vertical: 2.h),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined,size: 10.r),
                              CustomText(
                                left: 4.w,
                                maxline: 1,
                                textOverflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                text: '0.8 km away',fontSize: 10.sp,),
                            ],
                          ),
                        ),

                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 4.w,vertical: 2.h),
                          child: CustomButton(onPressed: (){},label: 'Join',width: 50.w,height: 15.h,fontSize: 8.sp,),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    )
    ;
  }
}
