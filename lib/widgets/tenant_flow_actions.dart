import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';

/// Compact paired navigation for workout questions, shared by both entry flows.
class TenantFlowActions extends StatelessWidget {
  const TenantFlowActions({
    super.key,
    required this.onNext,
    this.onSkip,
    this.nextLabel = 'Next',
    this.enabled = true,
  });

  final VoidCallback onNext;
  final VoidCallback? onSkip;
  final String nextLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = TenantBrandService.to.activeBrand?.theme ??
        EnterpriseGymTheme.of(context);
    Widget action(String label, VoidCallback? onTap, {required bool primary}) {
      return Expanded(
        child: Semantics(
          button: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                height: 44,
                decoration: primary
                    ? theme.accentDecoration(radius: 14, glow: false)
                    : BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.borderTint),
                      ),
                child: Center(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primary ? theme.textOnGradient : theme.selectedState,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: onSkip == null ? 240 : 340),
        child: Row(
          children: [
            if (onSkip != null) ...[
              action('Skip for now', onSkip, primary: false),
              const SizedBox(width: 10),
            ],
            action(nextLabel, onNext, primary: true),
          ],
        ),
      ),
    );
  }
}
