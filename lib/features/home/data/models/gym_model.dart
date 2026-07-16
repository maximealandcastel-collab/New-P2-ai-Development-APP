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
      imageUrl:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=220&h=124&fit=crop&q=80',
      distanceKm: 0.8,
    ),
    GymModel(
      id: '2',
      name: 'Iron Pulse Gym',
      imageUrl:
          'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=220&h=124&fit=crop&q=80',
      distanceKm: 1.2,
    ),
    GymModel(
      id: '4',
      name: 'Core Strength Hub',
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=220&h=124&fit=crop&q=80',
      distanceKm: 2.0,
    ),
    GymModel(
      id: '8',
      name: 'Elite Training Club',
      imageUrl:
          'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?w=220&h=124&fit=crop&q=80',
      distanceKm: 3.6,
    ),
    GymModel(
      id: '9',
      name: 'Active Life Center',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=220&h=124&fit=crop&q=80',
      distanceKm: 4.0,
    ),
  ];
}
