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

/// Stable identity for a nav tab, independent of its position.
///
/// The three nav sets order their tabs differently and have different lengths,
/// so no single integer literal can identify a tab across all of them. Code
/// that needs "the Contents tab" must resolve it by id via [NavItemModel.indexOf]
/// rather than hardcoding a position.
enum NavItemId {
  home,
  clients,
  gyms,
  contents,
  request,
  messages,
  admin,
  history,
  trainer,
  earnings,
}

class NavItemModel {
  final NavItemId id;
  final String icon;
  final String label;
  final Widget screen;

  const NavItemModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.screen,
  });

  /// Position of [id] within [items], or -1 when that set has no such tab.
  static int indexOf(List<NavItemModel> items, NavItemId id) =>
      items.indexWhere((e) => e.id == id);

  /// Trainer nav — Home · Clients · Gyms · Contents · Request · Messages
  static List<NavItemModel> trainerNavItems = [
    NavItemModel(
      id: NavItemId.home,
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const TrainerHomeScreen(),
    ),
    NavItemModel(
      id: NavItemId.clients,
      label: 'Clients',
      icon: Assets.icons.clients.path,
      screen: const ClientsScreen(),
    ),
    NavItemModel(
      id: NavItemId.gyms,
      label: 'Gyms',
      icon: Assets.icons.note.path,
      screen: const GymsScreen(),
    ),
    NavItemModel(
      id: NavItemId.contents,
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      id: NavItemId.request,
      label: 'Request',
      icon: Assets.icons.request.path,
      screen: const RequestScreen(),
    ),
    NavItemModel(
      id: NavItemId.messages,
      label: 'Messages',
      icon: Assets.icons.message.path,
      screen: const TrainerInboxScreen(),
    ),
  ];

  static NavItemModel get adminNavItem => NavItemModel(
        id: NavItemId.admin,
        label: 'Admin',
        icon: Assets.icons.star.path,
        screen: const AdminDashboardScreen(),
      );

  /// Admin nav — all trainer screens PLUS the Admin analytics tab.
  /// The admin experiences the full trainer workflow and has live platform
  /// analytics one tab away. Nothing is replaced; Admin is additive.
  static List<NavItemModel> adminNavItems = [
    NavItemModel(
      id: NavItemId.home,
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const TrainerHomeScreen(),
    ),
    NavItemModel(
      id: NavItemId.clients,
      label: 'Clients',
      icon: Assets.icons.clients.path,
      screen: const ClientsScreen(),
    ),
    NavItemModel(
      id: NavItemId.contents,
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      id: NavItemId.request,
      label: 'Request',
      icon: Assets.icons.request.path,
      screen: const RequestScreen(),
    ),
    NavItemModel(
      id: NavItemId.admin,
      label: 'Admin',
      icon: Assets.icons.star.path,
      screen: const AdminDashboardScreen(),
    ),
  ];

  static NavItemModel get affiliateNavItem => NavItemModel(
        id: NavItemId.earnings,
        label: 'Earnings',
        icon: Assets.icons.star.path,
        screen: const AffiliateDashboardScreen(),
      );

  static List<NavItemModel> userNavItems = [
    NavItemModel(
      id: NavItemId.home,
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const UserHomeScreen(),
    ),
    NavItemModel(
      id: NavItemId.history,
      label: 'History',
      icon: Assets.icons.history.path,
      screen: const HistoryScreen(),
    ),
    NavItemModel(
      id: NavItemId.gyms,
      label: 'Gyms',
      icon: Assets.icons.note.path,
      screen: const GymsScreen(),
    ),
    NavItemModel(
      id: NavItemId.contents,
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      id: NavItemId.trainer,
      label: 'Trainer',
      icon: Assets.icons.trainer.path,
      screen: const UserTrainerScreen(),
    ),
  ];
}
