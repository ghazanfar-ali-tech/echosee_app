import 'dart:async';
import 'dart:io';
import 'package:echosee_app/app_constants.dart';
import 'package:echosee_app/models/bluetooth_glass_device.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:echosee_app/models/model.dart';

enum BluetoothStatus { disconnected, connecting, connected, disconnecting }

class BluetoothProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool _isScanning = false;
  BluetoothStatus _status = BluetoothStatus.disconnected;
  BluetoothGlassesDevice? _connectedDevice;
  List<BluetoothGlassesDevice> _discoveredDevices = [];

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;
  BluetoothStatus get status => _status;
  BluetoothGlassesDevice? get connectedDevice => _connectedDevice;
  List<BluetoothGlassesDevice> get discoveredDevices => _discoveredDevices;

  BluetoothProvider() {
    initialize();
  }

  Future<void> initialize() async {
    FlutterBluePlus.adapterState.listen((state) {
      print('Bluetooth adapter state: $state');
      if (state != BluetoothAdapterState.on) {
        _isConnected = false;
        _status = BluetoothStatus.disconnected;
        _connectedDevice = null;
        notifyListeners();
      }
    });
  }

  BluetoothCharacteristic? _selectedCharacteristic;

  // Add these fields
  bool _isVerified = false;
  bool get isVerified => _isVerified;
  Timer? _pingTimer;
  int _missedPings = 0;
  static const int MAX_MISSED_PINGS = 3;

  // Call this right after discoverServices succeeds
  Future<void> _verifyConnection() async {
    if (_selectedCharacteristic == null) return;

    try {
      final bytes = 'PING'.codeUnits;
      await _selectedCharacteristic!.write(bytes, withoutResponse: false);
      print('[BLE] Sent PING, waiting for PONG...');
    } catch (e) {
      print('[BLE] Ping failed: $e');
      _isVerified = false;
      notifyListeners();
    }
  }

  // Call this in your characteristic listener
  void _handleIncomingMessage(String message) {
    if (message.trim() == 'PONG') {
      _isVerified = true;
      _missedPings = 0;
      notifyListeners();
      print('[BLE] Connection verified ✓');
      _startHeartbeat(); // keep monitoring
      return;
    }
    // handle other messages...
  }

  // Periodic heartbeat to detect silent disconnects
  void _startHeartbeat() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_selectedCharacteristic == null) return;
      try {
        await _selectedCharacteristic!.write('PING'.codeUnits);
        _missedPings++;
        if (_missedPings >= MAX_MISSED_PINGS) {
          print('[BLE] Device not responding, disconnecting...');
          disconnect();
        }
      } catch (_) {
        disconnect();
      }
    });
  }

  // Reset on disconnect
  void _onDisconnected() {
    _isVerified = false;
    _pingTimer?.cancel();
    _missedPings = 0;
    notifyListeners();
  }

  Future<bool> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        print('Requesting Bluetooth permissions for Android...');

        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();

        bool allGranted = statuses.values.every((status) => status.isGranted);

        if (!allGranted) {
          print('  Some permissions denied:');
          statuses.forEach((permission, status) {
            print('  $permission: $status');
          });
        } else {
          print('   All permissions granted');
        }

        return allGranted;
      } else if (Platform.isIOS) {
        print('iOS - permissions handled by system');
        return true;
      }

      return true;
    } catch (e) {
      print('  Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> _checkLocationService() async {
    if (Platform.isAndroid) {
      try {
        final serviceStatus = await Permission.location.serviceStatus;
        final isEnabled = serviceStatus.isEnabled;

        print('Location service enabled: $isEnabled');

        if (!isEnabled) {
          print(' Location services are OFF. Please enable them in settings.');
        }

        return isEnabled;
      } catch (e) {
        print('Error checking location service: $e');
        return false;
      }
    }
    return true;
  }

  Future<void> startScan() async {
    print(' Starting scan...');

    bool permissionsGranted = await _requestPermissions();
    if (!permissionsGranted) {
      print('  Permissions not granted. Cannot scan.');
      return;
    }
    print('   Permissions granted');

    bool locationEnabled = await _checkLocationService();
    if (!locationEnabled && Platform.isAndroid) {
      print('Location services disabled. Cannot scan on Android.');
      return;
    }

    bool isBluetoothOn = await FlutterBluePlus.isOn;
    if (!isBluetoothOn) {
      print('Bluetooth is OFF. Requesting to turn ON...');

      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      } else {
        print('Please enable Bluetooth in Settings');
      }
      return;
    }
    print('Bluetooth is ON');

    _discoveredDevices.clear();
    _isScanning = true;
    notifyListeners();

    try {
      await FlutterBluePlus.stopScan();

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );
      print('   Scan started successfully');

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          final Map<String, BluetoothGlassesDevice> deviceMap = {};

          for (var result in results) {
            final device = result.device;
            final rssi = result.rssi;

            String name = device.platformName;
            if (name.isEmpty) name = result.advertisementData.advName;
            if (name.isEmpty) name = result.advertisementData.localName;

            final serviceUuids = result.advertisementData.serviceUuids
                .map((u) => u.toString().toUpperCase())
                .toList();
            if (serviceUuids.contains(
              AppConstants.esp32ServiceUUID.toUpperCase(),
            )) {
              name = 'EchoSee Glasses';
            }

            if (name.isEmpty || name == 'Unknown Device') {
              name = 'Unnamed Device';
            }

            final id = device.remoteId.toString();

            final glassesDevice = BluetoothGlassesDevice(
              id: id,
              name: name,
              address: id,
              signalStrength: _getSignalStrengthText(rssi),
              signalBars: _getSignalBars(rssi),
              rssi: rssi,
              isConnected: _connectedDevice?.id == id,
              device: device,
            );

            if (!deviceMap.containsKey(id) ||
                (deviceMap[id]!.name == 'Unknown Device' &&
                    name != 'Unknown Device')) {
              deviceMap[id] = glassesDevice;
            }
          }

          _discoveredDevices = deviceMap.values.toList();
          _discoveredDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
          notifyListeners();
        },
        onError: (error) {
          print('Scan error: $error');
          _isScanning = false;
          notifyListeners();
        },
      );

      Future.delayed(const Duration(seconds: 10), () {
        if (_isScanning) {
          stopScan();
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    print('Stopping scan...');

    try {
      await FlutterBluePlus.stopScan();
      _isScanning = false;
      notifyListeners();
      print('   Scan stopped');
    } catch (e) {
      print('  Error stopping scan: $e');
    }
  }

  Future<void> connectToDevice(BluetoothGlassesDevice glassesDevice) async {
    print('Connecting to ${glassesDevice.name}...');

    try {
      await stopScan();

      _status = BluetoothStatus.connecting;
      notifyListeners();

      final device = glassesDevice.device;
      if (device == null) {
        print('Device object is null');
        _status = BluetoothStatus.disconnected;
        notifyListeners();
        return;
      }

      final connectionState = await device.connectionState.first;
      if (connectionState == BluetoothConnectionState.connected) {
        print('Already connected');
        _isConnected = true;
        _status = BluetoothStatus.connected;
        _connectedDevice = glassesDevice.copyWith(isConnected: true);
        notifyListeners();
        return;
      }

      try {
        await device.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Cleanup disconnect: $e');
      }

      int maxRetries = 3;
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print('Connection attempt $attempt/$maxRetries...');

          await device.connect(
            timeout: const Duration(seconds: 20),
            autoConnect: false,
          );

          print('Connection established on attempt $attempt');
          break;
        } catch (e) {
          print(' Attempt $attempt failed: $e');

          if (attempt < maxRetries) {
            print('Waiting before retry...');
            await Future.delayed(Duration(seconds: attempt));
          } else {
            print('All connection attempts failed');
            throw e;
          }
        }
      }

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        print('📡 Connection state: $state');

        if (state == BluetoothConnectionState.connected) {
          _isConnected = true;
          _status = BluetoothStatus.connected;
          _connectedDevice = glassesDevice.copyWith(isConnected: true);
          print('Successfully connected to ${glassesDevice.name}');
          notifyListeners();
        } else if (state == BluetoothConnectionState.disconnected) {
          _isConnected = false;
          _status = BluetoothStatus.disconnected;
          _connectedDevice = null;
          print('Disconnected from ${glassesDevice.name}');
          notifyListeners();
        }
      });

      try {
        print('Discovering services...');
        List<BluetoothService> services = await device.discoverServices();
        print('Found ${services.length} services');

        for (var service in services) {
          print('  Service: ${service.uuid}');
          for (var characteristic in service.characteristics) {
            print('    Characteristic: ${characteristic.uuid}');
          }
        }
      } catch (e) {
        print('Service discovery error: $e');
      }
    } catch (e) {
      print('Connection error: $e');
      _isConnected = false;
      _status = BluetoothStatus.disconnected;
      _connectedDevice = null;
      notifyListeners();

      _showConnectionError(e);
    }
  }

  void _showConnectionError(dynamic error) {
    String errorMessage;

    if (error.toString().contains('GATT_CONNECTION_TIMEOUT')) {
      errorMessage =
          'Connection timeout. Make sure your glasses are powered on and in pairing mode.';
    } else if (error.toString().contains('133')) {
      errorMessage =
          'Connection failed. Try restarting Bluetooth or your device.';
    } else {
      errorMessage = 'Failed to connect: ${error.toString()}';
    }

    print('User message: $errorMessage');
  }

  Future<void> disconnect() async {
    print('    Disconnecting...');

    try {
      _status = BluetoothStatus.disconnecting;
      notifyListeners();

      if (_connectedDevice?.device != null) {
        await _connectedDevice!.device!.disconnect();
      }

      _isConnected = false;
      _status = BluetoothStatus.disconnected;
      _connectedDevice = null;
      notifyListeners();
      print('   Disconnected');
    } catch (e) {
      print('  Disconnect error: $e');
      _status = BluetoothStatus.disconnected;
      notifyListeners();
    }
  }

  String _getSignalStrengthText(int rssi) {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    return 'Weak';
  }

  int _getSignalBars(int rssi) {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    return 1;
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    disconnect();
    super.dispose();
  }
}
