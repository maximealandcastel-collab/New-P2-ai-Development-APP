import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:pler_to_pler_app/features/affiliate/presentation/screens/affiliate_dashboard_screen.dart';
import 'package:pler_to_pler_app/features/home/trainer_home_screen.dart';
import 'package:pler_to_pler_app/features/home/user_home_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/clients_screen.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/contents_screen.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/request_screen.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/history_screen.dart';
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
      label: 'Contents',
      icon: Assets.icons.contents.path,
      screen: const ContentsScreen(),
    ),
    NavItemModel(
      label: 'Request',
      icon: Assets.icons.request.path,
      screen: const RequestScreen(),
    ),
  ];

  static NavItemModel get adminNavItem => NavItemModel(
        label: 'Admin',
        icon: Assets.icons.star.path,
        screen: const AdminDashboardScreen(),
      );

  /// Nav items for the admin account — Dashboard (real platform data) first,
  /// then the standard trainer tools (Clients, Contents, Request).
  /// No separate "Admin" tab needed because Home IS the dashboard.
  static List<NavItemModel> adminNavItems = [
    NavItemModel(
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const AdminDashboardScreen(),
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
  ];

  static NavItemModel get affiliateNavItem => NavItemModel(
        label: 'Earnings',
        icon: Assets.icons.star.path, // reuses star icon; swap if a wallet icon is available
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