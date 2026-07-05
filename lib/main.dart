import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pler_to_pler_app/core/di/dependency_injection.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await DependencyInjection.init();
  runApp(const MyApp());
}
