import 'tenant_configuration.dart';

/// Public branding only. This configuration never grants gym access.
const legacyKmfConfiguration = {
  "schemaVersion": 1,
  "id": "kmf-fitness",
  "name": "KMF Fitness Club",
  "slogan": "Keep Moving Forward",
  "logoUrl": "assets/images/gym_logos/kmf_fitness_club.jpg",
  "primaryColor": "#0A0A0A",
  "secondaryColor": "#171917",
  "accentColor": "#39FF14",
  "timezone": "America/New_York",
  "photos": [
    "assets/images/gym_photos/kmf_fitness_club_floor.jpg",
    "assets/images/gym_photos/kmf_fitness_club_exterior.jpg",
    "assets/images/gym_photos/kmf_fitness_club_equipment.jpg",
  ],
  "locations": [
    {
      "name": "Main facility",
      "address": "3361 Hempstead Tpke, Levittown, NY 11756",
      "city": "Levittown",
      "zipCode": "11756",
      "lat": 40.7259,
      "lng": -73.5143,
    },
  ],
  "contact": {},
  "category": "Boxing",
  "tags": ["Boxing", "Strength"],
};

TenantConfiguration get legacyKmfTenant =>
    TenantConfiguration.fromJson(legacyKmfConfiguration);
