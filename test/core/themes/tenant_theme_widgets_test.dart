import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/featured_gym_card.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/notification/data/models/notification_model.dart';
import 'package:pler_to_pler_app/features/notification/presentation/screen/widgets/notification_card_widget.dart';
import 'package:pler_to_pler_app/widgets/custom_button.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_sliver_app_bar.dart';
import 'package:pler_to_pler_app/widgets/sliver_scaffold.dart';

void main() {
  testWidgets(
    'shared controls and notifications follow tenant and reset themes',
    (tester) async {
      tester.view.physicalSize = const Size(1125, 2436);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final branded = ValueNotifier(true);
      addTearDown(branded.dispose);
      const green = Color(0xFF168A3A);
      const background = Color(0xFFF8FCF9);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => ValueListenableBuilder<bool>(
            valueListenable: branded,
            builder: (_, tenant, _) => MaterialApp(
              theme: tenant
                  ? AppThemeData.forBrand(
                      primaryColor: green,
                      scaffoldBackground: background,
                    )
                  : AppThemeData.themeData,
              home: SliverScaffold(
                onRefresh: () async {},
                appBar: const CustomSliverAppBar(title: 'Notifications'),
                bodyList: [
                  CustomButton(label: 'Continue', onPressed: () {}).asSliver,
                  CustomButton(
                    label: 'Override',
                    backgroundColor: Colors.blue,
                    onPressed: () {},
                  ).asSliver,
                  const NotificationCardWidget(
                    notification: NotificationModel(
                      id: '1',
                      message: 'Welcome!',
                      date: '9/8/26',
                      isRead: false,
                    ),
                  ).asSliver,
                  FeaturedGymCard(
                    gym: EnterpriseGymModel(
                      id: 'test-gym',
                      name: 'Test Gym',
                      initials: 'TG',
                      category: 'Boxing',
                      memberCount: '10',
                      brandColor: Colors.purple,
                      accentColor: Colors.purple,
                      isActivated: true,
                    ),
                  ).asSliver,
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Color? buttonColor(String label) => tester
          .widget<CustomContainer>(
            find
                .descendant(
                  of: find.widgetWithText(CustomButton, label),
                  matching: find.byType(CustomContainer),
                )
                .first,
          )
          .color;
      Color? notificationColor() => tester
          .widget<CustomContainer>(
            find
                .descendant(
                  of: find.byType(NotificationCardWidget),
                  matching: find.byType(CustomContainer),
                )
                .first,
          )
          .color;

      Color? gymActionColor() => tester
          .widget<Icon>(find.byKey(const ValueKey('featured-gym-open-icon')))
          .color;

      expect(gymActionColor(), green);
      expect(buttonColor('Continue'), green);
      expect(buttonColor('Override')?.toARGB32(), Colors.blue.toARGB32());
      expect(notificationColor(), green.withValues(alpha: 0.06));
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        background,
      );
      expect(
        tester.widget<RefreshIndicator>(find.byType(RefreshIndicator)).color,
        green,
      );

      branded.value = false;
      await tester.pumpAndSettle();
      expect(gymActionColor(), AppColors.primary);
      expect(buttonColor('Continue'), AppColors.primary);
      expect(buttonColor('Override')?.toARGB32(), Colors.blue.toARGB32());
      expect(notificationColor(), AppColors.primary.withValues(alpha: 0.06));
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        AppColors.backgroundLight,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
