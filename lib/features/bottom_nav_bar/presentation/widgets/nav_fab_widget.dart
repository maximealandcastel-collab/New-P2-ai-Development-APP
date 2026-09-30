import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';

class NavFabWidget {
  static bool _open = false;

  static Future<void> show(BuildContext context, List<NavFabModel> items) async {
    if (_open) return;
    _open = true;
    final theme = TenantBrandService.to.activeBrand?.theme ??
        Theme.of(context).extension<EnterpriseGymTheme>() ?? TenantBrandService.to.theme;
    final route = RawDialogRoute<NavFabModel>(
      barrierDismissible: true,
      barrierLabel: 'Close quick actions',
      barrierColor: Colors.black.withValues(alpha: .30),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) => TenantQuickActionMenu(items: items, theme: theme),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .025), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
    try {
      final selected = await Navigator.of(context, rootNavigator: true).push(route);
      // Wait for the overlay to reverse before opening the existing destination.
      await route.completed;
      selected?.onTap();
    } finally {
      _open = false;
    }
  }
}

class TenantQuickActionMenu extends StatefulWidget {
  const TenantQuickActionMenu({super.key, required this.items, required this.theme});
  final List<NavFabModel> items;
  final EnterpriseGymTheme theme;
  @override
  State<TenantQuickActionMenu> createState() => _TenantQuickActionMenuState();
}

class _TenantQuickActionMenuState extends State<TenantQuickActionMenu> {
  int? _selected;

  void _choose(int index) {
    if (_selected != null) return;
    setState(() => _selected = index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(widget.items[index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    BoxDecoration decoration(BorderRadius radius) => BoxDecoration(
      gradient: theme.ctaGradient,
      borderRadius: radius,
      border: Border.all(color: theme.primaryBrandColor.withValues(alpha: .55), width: .8),
      boxShadow: [BoxShadow(color: theme.primaryBrandColor.withValues(alpha: .12),
        blurRadius: 12, offset: const Offset(0, 3))],
    );
    return Stack(children: [
      Positioned.fill(child: IgnorePointer(child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: const SizedBox.expand(),
      ))),
      SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (var index = 0; index < widget.items.length; index++) ...[
              if (index > 0) const SizedBox(height: 10),
              Material(color: Colors.transparent, child: Ink(
                decoration: decoration(BorderRadius.circular(28)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: _selected == null ? () => _choose(index) : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      child: Row(children: [
                        Container(width: 34, height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .12)),
                          child: SvgPicture.asset(widget.items[index].icon,
                            width: 18, height: 18,
                            colorFilter: ColorFilter.mode(theme.textOnGradient, BlendMode.srcIn)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.items[index].label,
                          style: TextStyle(color: theme.textOnGradient, fontSize: 14,
                            fontWeight: AppFontWeight.section))),
                        const SizedBox(width: 8),
                        if (_selected == index)
                          SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2,
                              color: theme.textOnGradient))
                        else Icon(Icons.chevron_right_rounded, size: 20,
                          color: theme.textOnGradient),
                      ]),
                    ),
                  ),
                ),
              )),
            ],
            const SizedBox(height: 16),
            Material(color: Colors.transparent, child: Ink(
              decoration: decoration(BorderRadius.circular(24)),
              child: IconButton(
                tooltip: 'Close quick actions',
                onPressed: _selected == null ? () => Navigator.of(context).pop() : null,
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                icon: Icon(Icons.close_rounded, size: 23, color: theme.textOnGradient),
              ),
            )),
          ]),
        ),
      ))),
    ]);
  }
}
