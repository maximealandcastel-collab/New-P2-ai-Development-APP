import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/home/trainer_home_screen.dart';
import 'package:pler_to_pler_app/features/home/user_home_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/clients_screen.dart';
import 'package:pler_to_pler_app/features/trainer/contents/presentation/screens/contents_screen.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/request_screen.dart';
import 'package:pler_to_pler_app/features/user/history/presentation/screens/history_screen.dart';
import 'package:pler_to_pler_app/features/user/trainer/presentation/screens/user_trainer_screen.dart';
import 'package:pler_to_pler_app/features/user/workout_pan/presentation/workout_plan_screen.dart';

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