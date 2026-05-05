import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothGlassesDevice {
  final String id;
  final String name;
  final String address;
  final String signalStrength;
  final int signalBars;
  final int rssi;
  final bool isConnected;
  final BluetoothDevice? device; // The actual Bluetooth device object

  BluetoothGlassesDevice({
    required this.id,
    required this.name,
    required this.address,
    required this.signalStrength,
    required this.signalBars,
    required this.rssi,
    required this.isConnected,
    this.device,
  });

  // CopyWith method for creating modified copies
  BluetoothGlassesDevice copyWith({
    String? id,
    String? name,
    String? address,
    String? signalStrength,
    int? signalBars,
    int? rssi,
    bool? isConnected,
    BluetoothDevice? device,
  }) {
    return BluetoothGlassesDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      signalStrength: signalStrength ?? this.signalStrength,
      signalBars: signalBars ?? this.signalBars,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
      device: device ?? this.device,
    );
  }

  // Optional: toString for debugging
  @override
  String toString() {
    return 'BluetoothGlassesDevice(name: $name, address: $address, rssi: $rssi, connected: $isConnected)';
  }
}
