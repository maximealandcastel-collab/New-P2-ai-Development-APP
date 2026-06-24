class DeviceModel {
  const DeviceModel({
    required this.id,
    required this.name,
    required this.serialNumber,
    this.macAddress,
    this.deviceType,
    this.isConnected = false,
    this.isPrimary = false,
    this.lastSyncedAt,
  });

  final String id;
  final String name;
  final String serialNumber;
  final String? macAddress;
  final String? deviceType;
  final bool isConnected;
  final bool isPrimary;
  final DateTime? lastSyncedAt;

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['deviceName']?.toString() ?? '',
      serialNumber: json['serialNumber']?.toString() ??
          json['serial']?.toString() ??
          '',
      macAddress: json['macAddress']?.toString(),
      deviceType: json['deviceType']?.toString(),
      isConnected: json['isConnected'] == true || json['status'] == 'connected',
      isPrimary: json['isPrimary'] == true,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serialNumber': serialNumber,
        'macAddress': macAddress,
        'deviceType': deviceType,
        'isConnected': isConnected,
        'isPrimary': isPrimary,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      };

  DeviceModel copyWith({
    String? id,
    String? name,
    String? serialNumber,
    String? macAddress,
    String? deviceType,
    bool? isConnected,
    bool? isPrimary,
    DateTime? lastSyncedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      serialNumber: serialNumber ?? this.serialNumber,
      macAddress: macAddress ?? this.macAddress,
      deviceType: deviceType ?? this.deviceType,
      isConnected: isConnected ?? this.isConnected,
      isPrimary: isPrimary ?? this.isPrimary,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class BluetoothScanResultModel {
  const BluetoothScanResultModel({
    required this.id,
    required this.name,
    this.macAddress,
  });

  final String id;
  final String name;
  final String? macAddress;
}
