import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:pler_to_pler_app/features/affiliate/presentation/screens/affiliate_dashboard_screen.dart';
import 'package:pler_to_pler_app/features/home/trainer_home_screen.dart';
import 'package:pler_to_pler_app/features/home/user_home_screen.dart';
import 'package:pler_to_pler_app/features/messaging/trainer_inbox_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/clients_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/contents_screen.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/request_screen.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/history_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gyms_screen.dart';
import 'package:pler_to_pler_app/features/user/trainer/presentation/screens/user_trainer_screen.dart';

class NavItemModel {
  final String icon;
  final String label;
  final Widget screen;

  const NavItemModel({
    required this.icon,
    required this.label,
    required this.screen,
  });

  /// Trainer nav — Home · Clients · Gyms · Contents · Request · Messages
  static List<NavItemModel> trainerNavItems = [
    NavItemModel(
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const TrainerHomeScreen(),
    ),
    NavItemModel(
      label: 'Clients',
      icon: Assets.icons.clients.path,
      screen: const ClientsScreen(),
    ),
    NavItemModel(
      label: 'Gyms',
      icon: Assets.icons.note.path,
      screen: const GymsScreen(),
    ),
    NavItemModel(
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      label: 'Request',
      icon: Assets.icons.request.path,
      screen: const RequestScreen(),
    ),
    NavItemModel(
      label: 'Messages',
      icon: Assets.icons.message.path,
      screen: const TrainerInboxScreen(),
    ),
  ];

  static NavItemModel get adminNavItem => NavItemModel(
        label: 'Admin',
        icon: Assets.icons.star.path,
        screen: const AdminDashboardScreen(),
      );

  /// Admin nav — all trainer screens PLUS the Admin analytics tab.
  /// The admin experiences the full trainer workflow and has live platform
  /// analytics one tab away. Nothing is replaced; Admin is additive.
  static List<NavItemModel> adminNavItems = [
    NavItemModel(
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const TrainerHomeScreen(),
    ),
    NavItemModel(
      label: 'Clients',
      icon: Assets.icons.clients.path,
      screen: const ClientsScreen(),
    ),
    NavItemModel(
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      label: 'Request',
      icon: Assets.icons.request.path,
      screen: const RequestScreen(),
    ),
    NavItemModel(
      label: 'Admin',
      icon: Assets.icons.star.path,
      screen: const AdminDashboardScreen(),
    ),
  ];

  static NavItemModel get affiliateNavItem => NavItemModel(
        label: 'Earnings',
        icon: Assets.icons.star.path,
        screen: const AffiliateDashboardScreen(),
      );

  static List<NavItemModel> userNavItems = [
    NavItemModel(
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const UserHomeScreen(),
    ),
    NavItemModel(
      label: 'History',
      icon: Assets.icons.history.path,
      screen: const HistoryScreen(),
    ),
    NavItemModel(
      label: 'Gyms',
      icon: Assets.icons.note.path,
      screen: const GymsScreen(),
    ),
    NavItemModel(
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      label: 'Trainer',
      icon: Assets.icons.trainer.path,
      screen: const UserTrainerScreen(),
    ),
  ];
}
