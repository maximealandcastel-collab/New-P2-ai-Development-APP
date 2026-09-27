import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/themes/p2p_design_tokens.dart';
import 'package:pler_to_pler_app/features/community/presentation/controllers/before_after_controller.dart';

class BeforeAfterScreen extends StatelessWidget {
  const BeforeAfterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BeforeAfterController());
    final accent = BrandColors.of(context).primary;
    return Scaffold(
      backgroundColor: P2PColors.surface,
      appBar: AppBar(
        backgroundColor: P2PColors.surface,
        surfaceTintColor: P2PColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 19, color: P2PColors.charcoal),
          onPressed: Get.back,
        ),
        title: Text(
          'Post Progress',
          style: TextStyle(
            color: P2PColors.charcoal,
            fontWeight: AppFontWeight.section,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share your transformation',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: P2PColors.charcoal,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Inspire the community with your before & after.',
                style: TextStyle(fontSize: 13, height: 1.4,
                    color: P2PColors.secondaryText),
              ),
              const SizedBox(height: 24),

              // Photo pickers
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _PhotoPicker(
                          label: 'Before',
                          file: controller.beforeFile.value,
                          onTap: controller.pickBefore,
                          accentColor: accent,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => _PhotoPicker(
                          label: 'After',
                          file: controller.afterFile.value,
                          onTap: controller.pickAfter,
                          accentColor: accent,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Caption
              const Text(
                'Caption (optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: AppFontWeight.label,
                  color: P2PColors.charcoal,
                ),
              ),
              const SizedBox(height: 9),
              TextFormField(
                maxLines: 3,
                maxLength: 280,
                style: const TextStyle(fontSize: 14, height: 1.4,
                    color: P2PColors.charcoal),
                decoration: InputDecoration(
                  hintText: 'Describe your journey...',
                  hintStyle: const TextStyle(color: P2PColors.tertiaryText,
                      fontSize: 14),
                  filled: true,
                  fillColor: P2PColors.surface,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(P2PRadius.card),
                    borderSide: const BorderSide(color: P2PColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(P2PRadius.card),
                    borderSide: const BorderSide(color: P2PColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(P2PRadius.card),
                    borderSide: BorderSide(color: accent, width: 1.1),
                  ),
                ),
                onChanged: (v) => controller.caption.value = v,
              ),
              const SizedBox(height: 23),

              // Result message
              Obx(() {
                final msg = controller.submitMessage.value;
                if (msg == null) return const SizedBox.shrink();
                return AnimatedContainer(
                  duration: P2PMotion.standard,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: controller.isSuccess.value
                        ? Colors.green[50]
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(P2PRadius.control),
                    border: Border.all(
                      color: controller.isSuccess.value
                          ? Colors.green[300]!
                          : Colors.red[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.isSuccess.value
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: controller.isSuccess.value
                            ? Colors.green[700]
                            : Colors.red[700],
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          msg,
                          style: TextStyle(
                            color: controller.isSuccess.value
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Submit button
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed:
                          controller.isSubmitting.value ? null : controller.submit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: P2PColors.charcoal,
                        backgroundColor: P2PColors.surface,
                        side: BorderSide(color: accent, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(P2PRadius.pill),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: accent,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Post to Community',
                                    style: TextStyle(fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded,
                                    color: accent, size: 19),
                              ],
                            ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onTap;
  final Color accentColor;

  const _PhotoPicker({
    required this.label,
    required this.file,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label photo, tap to select',
      child: Material(
        color: P2PColors.surface,
        borderRadius: BorderRadius.circular(P2PRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(P2PRadius.card),
          child: Container(
            height: 166,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(P2PRadius.card),
              border: Border.all(
                color: file != null ? accentColor : P2PColors.border,
                width: file != null ? 1.2 : 1,
              ),
              boxShadow: P2PShadows.card,
            ),
            clipBehavior: Clip.antiAlias,
            child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(file!, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 15),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .09),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: accentColor,
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: P2PColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to select',
                    style: TextStyle(fontSize: 11,
                        color: P2PColors.secondaryText),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}
