import 'package:flutter/material.dart';

class EnterpriseGymModel {
  static const Map<String, String> _localLogoAssets = {
    'p2p_fit_factor': 'assets/images/facility_app_logo.png',
    'la_fitness': 'assets/images/gym_logos/la_fitness.jpg',
    'yogasix': 'assets/images/gym_logos/yogasix.png',
  };

  static const Map<String, String> _officialDomains = {
    'la_fitness': 'lafitness.com',
    'yogasix': 'yogasix.com',
    'cyclebar': 'cyclebar.com',
    'hotworx': 'hotworx.net',
    'burn_boot_camp': 'burnbootcamp.com',
    'planet_fitness': 'planetfitness.com',
    'club_pilates': 'clubpilates.com',
    'retro_fitness': 'retrofitness.com',
    'snap_fitness': 'snapfitness.com',
    'd1_training': 'd1training.com',
    'crunch_fitness': 'crunch.com',
    'f45_training': 'f45training.com',
    'orangetheory': 'orangetheory.com',
    'pure_barre': 'purebarre.com',
    'jazzercise': 'jazzercise.com',
    'anytime_fitness': 'anytimefitness.com',
    'golds_gym': 'goldsgym.com',
    'equinox': 'equinox.com',
    'barrys': 'barrys.com',
    'soulcycle': 'soul-cycle.com',
    'corepower': 'corepoweryoga.com',
  };

  final String id;
  final String name;
  final String initials;
  final String category;
  final String memberCount;
  final Color brandColor;
  final Color accentColor;
  final Color textColor;
  final bool isActive;
  final bool isOwnGym;
  final bool isActivated; // true = visible in the app; false = contract not signed yet
  final double rating;
  final String imageUrl;
  final List<String> filterTags;
  final String city;
  final String zipCode;
  final double lat;
  final double lng;
  double? distanceMi;
  /// Partnership status shown on every non-activated Gym.
  final String statusLabel;

  EnterpriseGymModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.category,
    required this.memberCount,
    required this.brandColor,
    required this.accentColor,
    this.textColor = Colors.white,
    this.isActive = true,
    this.isOwnGym = false,
    this.isActivated = false,
    this.rating = 4.5,
    this.imageUrl = '',
    this.filterTags = const [],
    this.city = '',
    this.zipCode = '',
    this.lat = 0.0,
    this.lng = 0.0,
    this.distanceMi,
    this.statusLabel =
        'Targeted integration — partnership not yet established.',
  });

  String get distanceLabel {
    if (distanceMi == null) return '';
    if (distanceMi! < 0.1) return '< 0.1 mi';
    return '${distanceMi!.toStringAsFixed(1)} mi';
  }

  String get logoUrl {
    final domain = _officialDomains[id];
    if (domain == null) return '';
    return Uri.https(
      'www.google.com',
      '/s2/favicons',
      <String, String>{
        'domain_url': 'https://$domain',
        'sz': '128',
      },
    ).toString();
  }

  String get logoAssetPath => _localLogoAssets[id] ?? '';

  /// All 22 gyms — stored regardless of contract status.
  static List<EnterpriseGymModel> get partners => _partners;

  /// Only gyms with a signed contract. Use this everywhere in the app UI.
  static List<EnterpriseGymModel> get activatedPartners =>
      _partners.where((g) => g.isActivated).toList();

  static final List<EnterpriseGymModel> _partners = [
    // ── P2P's OWN GYM — ACTIVATED (brick & mortar) ──────────────────────
    EnterpriseGymModel(
      id: 'p2p_fit_factor',
      name: 'P2P Fit Factor',
      initials: 'P2F',
      category: 'P2P Partner Gym',
      memberCount: '2.4K members',
      brandColor: const Color(0xFFFF6B35),
      accentColor: const Color(0xFFFF8C00),
      isOwnGym: true,
      isActive: true,
      isActivated: true, // ✅ LIVE — brick & mortar
      rating: 4.9,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT', 'Strength', 'Cycling'],
      city: 'Miami',
      zipCode: '33101',
      lat: 25.7617,
      lng: -80.1918,
    ),

    // ── Enterprise Partners ──────────────────────────────────────────────
    EnterpriseGymModel(
      id: 'la_fitness',
      name: 'LA Fitness',
      initials: 'LAF',
      category: 'Multi-Sport',
      memberCount: '24.8K members',
      brandColor: const Color(0xFF1A1A2E),
      accentColor: const Color(0xFFD4AF37),
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength', 'HIIT', 'Cycling'],
      city: 'Los Angeles',
      zipCode: '90001',
      lat: 34.0522,
      lng: -118.2437,
    ),
    EnterpriseGymModel(
      id: 'yogasix',
      name: 'YogaSix',
      initials: 'Y6',
      category: 'Yoga & Wellness',
      memberCount: '8.2K members',
      brandColor: const Color(0xFF1B4332),
      accentColor: const Color(0xFF52B788),
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Yoga'],
      city: 'Chicago',
      zipCode: '60601',
      lat: 41.8781,
      lng: -87.6298,
    ),
    EnterpriseGymModel(
      id: 'cyclebar',
      name: 'CycleBar',
      initials: 'CB',
      category: 'Indoor Cycling',
      memberCount: '11.4K members',
      brandColor: const Color(0xFF0D0D0D),
      accentColor: const Color(0xFFE63946),
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Cycling'],
      city: 'New York',
      zipCode: '10001',
      lat: 40.7128,
      lng: -74.0060,
    ),
    EnterpriseGymModel(
      id: 'hotworx',
      name: 'HOTWORX',
      initials: 'HWX',
      category: 'Infrared Fitness',
      memberCount: '9.8K members',
      brandColor: const Color(0xFF7B0D1E),
      accentColor: const Color(0xFFFF4D6D),
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT', 'Pilates'],
      city: 'Nashville',
      zipCode: '37201',
      lat: 36.1627,
      lng: -86.7816,
    ),
    EnterpriseGymModel(
      id: 'burn_boot_camp',
      name: 'Burn Boot Camp',
      initials: 'BBC',
      category: 'Boot Camp',
      memberCount: '6.2K members',
      brandColor: const Color(0xFFE85D04),
      accentColor: const Color(0xFFFAA307),
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT', 'Strength'],
      city: 'Charlotte',
      zipCode: '28201',
      lat: 35.2271,
      lng: -80.8431,
    ),
    EnterpriseGymModel(
      id: 'planet_fitness',
      name: 'Planet Fitness',
      initials: 'PF',
      category: 'Value Gym',
      memberCount: '89K members',
      brandColor: const Color(0xFF7209B7),
      accentColor: const Color(0xFFFFD60A),
      rating: 4.2,
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength'],
      city: 'Hampton',
      zipCode: '03842',
      lat: 42.9956,
      lng: -71.0453,
    ),
    EnterpriseGymModel(
      id: 'club_pilates',
      name: 'Club Pilates',
      initials: 'CP',
      category: 'Pilates',
      memberCount: '7.4K members',
      brandColor: const Color(0xFF0D7377),
      accentColor: const Color(0xFF14BDAC),
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Pilates'],
      city: 'San Diego',
      zipCode: '92101',
      lat: 32.7157,
      lng: -117.1611,
    ),
    EnterpriseGymModel(
      id: 'retro_fitness',
      name: 'Retro Fitness',
      initials: 'RF',
      category: 'Full-Service Gym',
      memberCount: '5.1K members',
      brandColor: const Color(0xFFD00000),
      accentColor: const Color(0xFFFFBA08),
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength', 'HIIT'],
      city: 'Wyckoff',
      zipCode: '07481',
      lat: 41.0036,
      lng: -74.1679,
    ),
    EnterpriseGymModel(
      id: 'snap_fitness',
      name: 'Snap Fitness',
      initials: 'SF',
      category: '24/7 Gym',
      memberCount: '11.2K members',
      brandColor: const Color(0xFFBF0603),
      accentColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFBF0603),
      rating: 4.3,
      imageUrl:
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength'],
      city: 'Chanhassen',
      zipCode: '55317',
      lat: 44.8651,
      lng: -93.5294,
    ),
    EnterpriseGymModel(
      id: 'd1_training',
      name: 'D1 Training',
      initials: 'D1',
      category: 'Athletic Training',
      memberCount: '3.8K members',
      brandColor: const Color(0xFF0A0A0A),
      accentColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFF0A0A0A),
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT', 'Strength'],
      city: 'Nashville',
      zipCode: '37201',
      lat: 36.1627,
      lng: -86.7816,
    ),
    EnterpriseGymModel(
      id: 'crunch_fitness',
      name: 'Crunch Fitness',
      initials: 'CF',
      category: 'Affordable Gym',
      memberCount: '18.2K members',
      brandColor: const Color(0xFFE87722),
      accentColor: const Color(0xFF000000),
      rating: 4.2,
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength', 'HIIT'],
      city: 'New York',
      zipCode: '10001',
      lat: 40.7128,
      lng: -74.0060,
    ),
    EnterpriseGymModel(
      id: 'f45_training',
      name: 'F45 Training',
      initials: 'F45',
      category: 'Functional Training',
      memberCount: '9.6K members',
      brandColor: const Color(0xFF0D0D0D),
      accentColor: const Color(0xFFFF6B35),
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT'],
      city: 'Santa Monica',
      zipCode: '90401',
      lat: 34.0195,
      lng: -118.4912,
    ),
    EnterpriseGymModel(
      id: 'orangetheory',
      name: 'Orangetheory',
      initials: 'OTF',
      category: 'Heart Rate Training',
      memberCount: '31K members',
      brandColor: const Color(0xFFFF6B35),
      accentColor: const Color(0xFFFFFFFF),
      textColor: const Color(0xFFFF6B35),
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT', 'Strength'],
      city: 'Fort Lauderdale',
      zipCode: '33301',
      lat: 26.1224,
      lng: -80.1373,
    ),
    EnterpriseGymModel(
      id: 'pure_barre',
      name: 'Pure Barre',
      initials: 'PB',
      category: 'Barre Fitness',
      memberCount: '6.8K members',
      brandColor: const Color(0xFFF5E6D3),
      accentColor: const Color(0xFF8B5E52),
      textColor: const Color(0xFF8B5E52),
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Pilates'],
      city: 'Charleston',
      zipCode: '29401',
      lat: 32.7765,
      lng: -79.9311,
    ),
    EnterpriseGymModel(
      id: 'jazzercise',
      name: 'Jazzercise',
      initials: 'JZ',
      category: 'Dance Fitness',
      memberCount: '4.2K members',
      brandColor: const Color(0xFF6A0572),
      accentColor: const Color(0xFFE040FB),
      rating: 4.5,
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT'],
      city: 'Carlsbad',
      zipCode: '92008',
      lat: 33.1581,
      lng: -117.3506,
    ),
    EnterpriseGymModel(
      id: 'anytime_fitness',
      name: 'Anytime Fitness',
      initials: 'AF',
      category: '24/7 Gym',
      memberCount: '52K members',
      brandColor: const Color(0xFF4A2C6E),
      accentColor: const Color(0xFFAB84D8),
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength'],
      city: 'Hastings',
      zipCode: '55033',
      lat: 44.7441,
      lng: -92.8530,
    ),
    EnterpriseGymModel(
      id: 'golds_gym',
      name: "Gold's Gym",
      initials: 'GG',
      category: 'Classic Gym',
      memberCount: '15.3K members',
      brandColor: const Color(0xFF1A1A1A),
      accentColor: const Color(0xFFFFD700),
      rating: 4.4,
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength'],
      city: 'Venice',
      zipCode: '90291',
      lat: 33.9850,
      lng: -118.4695,
    ),
    EnterpriseGymModel(
      id: 'equinox',
      name: 'Equinox',
      initials: 'EQ',
      category: 'Luxury Fitness',
      memberCount: '22.1K members',
      brandColor: const Color(0xFF0A0A0A),
      accentColor: const Color(0xFFCCAA66),
      rating: 4.8,
      imageUrl:
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Strength', 'Yoga', 'Cycling'],
      city: 'New York',
      zipCode: '10022',
      lat: 40.7580,
      lng: -73.9855,
      statusLabel: 'Targeted integration — partnership not yet established.',
    ),
    EnterpriseGymModel(
      id: 'barrys',
      name: "Barry's",
      initials: 'BB',
      category: 'HIIT Bootcamp',
      memberCount: '8.7K members',
      brandColor: const Color(0xFF8B0000),
      accentColor: const Color(0xFFFF3333),
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=480&h=260&fit=crop&q=80',
      filterTags: const ['HIIT'],
      city: 'West Hollywood',
      zipCode: '90046',
      lat: 34.0900,
      lng: -118.3617,
    ),
    EnterpriseGymModel(
      id: 'soulcycle',
      name: 'SoulCycle',
      initials: 'SC',
      category: 'Indoor Cycling',
      memberCount: '14.5K members',
      brandColor: const Color(0xFF1A1A1A),
      accentColor: const Color(0xFFFFD700),
      rating: 4.6,
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Cycling'],
      city: 'New York',
      zipCode: '10023',
      lat: 40.7756,
      lng: -73.9811,
    ),
    EnterpriseGymModel(
      id: 'corepower',
      name: 'CorePower Yoga',
      initials: 'CPY',
      category: 'Hot Yoga',
      memberCount: '9.4K members',
      brandColor: const Color(0xFF005F73),
      accentColor: const Color(0xFF94D2BD),
      rating: 4.7,
      imageUrl:
          'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=480&h=260&fit=crop&q=80',
      filterTags: const ['Yoga'],
      city: 'Denver',
      zipCode: '80202',
      lat: 39.7392,
      lng: -104.9903,
    ),
  ];
}
