class GymModel {
  final String id;
  final String name;
  final String imageUrl;
  final double distanceKm;

  const GymModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.distanceKm,
  });

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km away';

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'distanceKm': distanceKm,
    };
  }

  static const List<GymModel> demoGyms = [
    GymModel(
      id: '1',
      name: 'StrongFit Downtown',
      imageUrl: 'https://picsum.photos/220/124?random=21',
      distanceKm: 0.8,
    ),
    GymModel(
      id: '2',
      name: 'Iron Pulse Gym',
      imageUrl: 'https://picsum.photos/220/124?random=22',
      distanceKm: 1.2,
    ),
    GymModel(
      id: '3',
      name: 'Flex Zone Fitness',
      imageUrl: 'https://picsum.photos/220/124?random=23',
      distanceKm: 1.5,
    ),
    GymModel(
      id: '4',
      name: 'Core Strength Hub',
      imageUrl: 'https://picsum.photos/220/124?random=24',
      distanceKm: 2.0,
    ),
    GymModel(
      id: '5',
      name: 'Peak Performance',
      imageUrl: 'https://picsum.photos/220/124?random=25',
      distanceKm: 2.4,
    ),
    GymModel(
      id: '6',
      name: 'Urban Fit Studio',
      imageUrl: 'https://picsum.photos/220/124?random=26',
      distanceKm: 2.8,
    ),
    GymModel(
      id: '7',
      name: 'PowerHouse Athletics',
      imageUrl: 'https://picsum.photos/220/124?random=27',
      distanceKm: 3.1,
    ),
    GymModel(
      id: '8',
      name: 'Elite Training Club',
      imageUrl: 'https://picsum.photos/220/124?random=28',
      distanceKm: 3.6,
    ),
    GymModel(
      id: '9',
      name: 'Active Life Center',
      imageUrl: 'https://picsum.photos/220/124?random=29',
      distanceKm: 4.0,
    ),
    GymModel(
      id: '10',
      name: 'FitNation Express',
      imageUrl: 'https://picsum.photos/220/124?random=30',
      distanceKm: 4.5,
    ),
  ];
}
