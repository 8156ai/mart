import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/clients/presentation/screens/project_page.dart';
import '../../features/clients/presentation/screens/archive_page.dart';
import '../../features/pricing/presentation/screens/tariff_settings_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const ProjectPage(),
    ),
    GoRoute(
      path: '/archive',
      builder: (_, __) => const ArchivePage(),
    ),
    GoRoute(
      path: '/tariffs',
      builder: (_, __) => const TariffSettingsPage(),
    ),
  ],
);