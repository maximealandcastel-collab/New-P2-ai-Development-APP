// import 'dart:developer';

// import 'package:flutter/material.dart';

// import '../../utils/constants/app_sizes.dart';
// import 'custom_text.dart';
// import '../../utils/constants/app_colors.dart';

// class CustomDropdownField extends StatelessWidget {
//   final String? label;
//   final String hintText;
//   final bool withAsterisk;
//   final List<String> items;
//   final String selectedValue;
//   final Color? borderColor;
//   final ValueChanged<String> onChanged;
//   final double? borderRedius;

//   const CustomDropdownField({
//     super.key,
//     this.label,
//     required this.hintText,
//     this.withAsterisk = false,
//     required this.items,
//     required this.selectedValue,
//     this.borderColor = const Color(0xffB8B8B8),
//     required this.onChanged,
//     this.borderRedius,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Label with red asterisk
//         // RichText(
//         //   text: TextSpan(
//         //     children: [
//         //       TextSpan(
//         //         text: label,
//         //         style: GoogleFonts.poppins(
//         //           fontSize: getWidth(16),
//         //           color: AppColors.formLabel,
//         //         ),
//         //       ),
//         //       if (withAsterisk)
//         //         TextSpan(
//         //           text: '*',
//         //           style: GoogleFonts.poppins(
//         //             fontSize: getWidth(14),
//         //             color: AppColors.asteriskColor,
//         //           ),
//         //         ),
//         //     ],
//         //   ),
//         // ),
//         //SizedBox(height: getHeight(6)),

//         /// Dropdown field with PopupMenu
//         GestureDetector(
//           onTap: () {
//             log("I am hear");
//             PopupMenuButton<String>(
//               color: Colors.white,
//               onSelected: onChanged,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               constraints: BoxConstraints(
//                 maxWidth: getWidth(500),
//                 maxHeight: getHeight(400),
//               ),
//               offset: Offset(getWidth(0), getHeight(20)),
//               child: Icon(Icons.keyboard_arrow_down, size: getHeight(24)),
//               // Popup menu items
//               itemBuilder: (context) {
//                 return items.map((item) {
//                   return PopupMenuItem<String>(
//                     value: item,
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: CustomText(
//                         text: item,
//                         fontWeight: FontWeight.w500,
//                         fontSize: getWidth(16),
//                       ),
//                     ),
//                   );
//                 }).toList();
//               },
//             );
//           },
//           child: Container(
//             // height: getHeight(48),
//             padding: EdgeInsets.symmetric(
//               horizontal: getWidth(18),
//               vertical: getHeight(18),
//             ),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(borderRedius ?? 4),
//               border: Border.all(
//                 color: AppColors.textFormFieldBorder,
//                 width: getWidth(1),
//               ),
//               color: AppColors.textWhite,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Selected Value or Hint Text
//                 CustomText(
//                   textOverflow: TextOverflow.ellipsis,
//                   fontWeight: FontWeight.w500,
//                   fontSize: getWidth(14),
//                   text: selectedValue.isEmpty ? hintText : selectedValue,
//                   textColor: selectedValue.isEmpty
//                       ? AppColors.textPrimary
//                       : AppColors.textPrimary,
//                 ),

//                 // Dropdown Icon with PopupMenuButton
//                 PopupMenuButton<String>(
//                   color: Colors.white,
//                   onSelected: onChanged,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   constraints: BoxConstraints(
//                     maxWidth: getWidth(500),
//                     maxHeight: getHeight(400),
//                   ),
//                   offset: Offset(getWidth(0), getHeight(20)),
//                   child: Icon(Icons.keyboard_arrow_down, size: getHeight(24)),
//                   // Popup menu items
//                   itemBuilder: (context) {
//                     return items.map((item) {
//                       return PopupMenuItem<String>(
//                         value: item,
//                         child: Align(
//                           alignment: Alignment.centerLeft,
//                           child: CustomText(
//                             text: item,
//                             fontWeight: FontWeight.w500,
//                             fontSize: getWidth(16),
//                           ),
//                         ),
//                       );
//                     }).toList();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../utils/constants/app_sizes.dart';
import '../../utils/constants/app_colors.dart';
import 'custom_text.dart';

class CustomDropdownField extends StatelessWidget {
  final String? label;
  final String hintText;
  final bool withAsterisk;
  final List<String> items;
  final String selectedValue;
  final Color? borderColor;
  final ValueChanged<String> onChanged;
  final double? borderRedius;

  const CustomDropdownField({
    super.key,
    this.label,
    required this.hintText,
    this.withAsterisk = false,
    required this.items,
    required this.selectedValue,
    this.borderColor,
    required this.onChanged,
    this.borderRedius,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          onSelected: onChanged,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          constraints: BoxConstraints(
            maxWidth: getWidth(500),
            maxHeight: getHeight(400),
          ),
          position: PopupMenuPosition.under,
          offset: Offset(getWidth(0.7), getHeight(10)),
          itemBuilder: (context) {
            return items.map((item) {
              return PopupMenuItem<String>(
                value: item,
                child: CustomText(
                  text: item,
                  fontWeight: FontWeight.w500,
                  fontSize: getWidth(16),
                ),
              );
            }).toList();
          },

          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getWidth(18),
              vertical: getHeight(18),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRedius ?? 4),
              border: Border.all(
                color: borderColor ?? AppColors.textFormFieldBorder,
                width: getWidth(1),
              ),
              color: AppColors.textWhite,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    textOverflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                    fontSize: getWidth(14),
                    text: selectedValue.isEmpty ? hintText : selectedValue,
                    textColor: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: getHeight(24),
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
