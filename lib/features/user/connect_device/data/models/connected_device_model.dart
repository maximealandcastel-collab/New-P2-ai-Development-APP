class ConnectedDeviceModel {
  const ConnectedDeviceModel({
    required this.id,
    required this.name,
    required this.serial,
  });

  final String id;
  final String name;
  final String serial;

  factory ConnectedDeviceModel.fromJson(Map<String, dynamic> json) {
    return ConnectedDeviceModel(
      id: json['id']?.toString() ?? json['serial']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      serial: json['serial']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serial': serial,
      };
}
