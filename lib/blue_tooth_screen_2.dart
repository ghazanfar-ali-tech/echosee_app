// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// class BleHomePage extends StatefulWidget {
//   const BleHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<BleHomePage> createState() => _BleHomePageState();
// }

// class _BleHomePageState extends State<BleHomePage> {
//   // Device and connection states
//   List<ScanResult> _scanResults = [];
//   BluetoothDevice? _connectedDevice;
//   BluetoothConnectionState _connectionState =
//       BluetoothConnectionState.disconnected;
//   List<BluetoothService> _services = [];
//   BluetoothCharacteristic? _selectedCharacteristic;

//   // Scanning state
//   bool _isScanning = false;
//   BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

//   // Messaging
//   final List<Map<String, String>> _messages = [];
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   // UUIDs - MATCH THESE with your laptop's advertiser
//   final String TARGET_DEVICE_NAME =
//       "ESP32-Test"; // Change this to match your laptop's advertising name
//   final String SERVICE_UUID = "da847298-e24c-4a69-9e34-5c5f54b7488f";
//   final String CHARACTERISTIC_UUID = "8ebf6254-80f7-48a3-9b85-74f62ae0dda6";

//   // Subscriptions cleanup
//   final List<StreamSubscription> _subscriptions = [];

//   @override
//   void initState() {
//     super.initState();
//     _initBluetooth();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     for (var sub in _subscriptions) {
//       sub.cancel();
//     }
//     FlutterBluePlus.stopScan();
//     super.dispose();
//   }

//   // ==================== BLUETOOTH INITIALIZATION ====================

//   Future<void> _initBluetooth() async {
//     // Check if Bluetooth is supported
//     final isSupported = await FlutterBluePlus.isSupported;
//     if (!isSupported) {
//       _showSnackBar('Bluetooth not supported on this device');
//       return;
//     }

//     // Request location permission (required for Android BLE scanning)
//     final locationStatus = await Permission.location.request();
//     if (locationStatus.isDenied) {
//       _showSnackBar('Location permission required for BLE scanning');
//       return;
//     } else if (locationStatus.isPermanentlyDenied) {
//       openAppSettings();
//       return;
//     }

//     // Listen to adapter state changes
//     final adapterSub = FlutterBluePlus.adapterState.listen((state) {
//       setState(() {
//         _adapterState = state;
//       });

//       if (state == BluetoothAdapterState.on) {
//         _showSnackBar('Bluetooth is ON');
//       } else if (state == BluetoothAdapterState.off) {
//         setState(() {
//           _scanResults.clear();
//           _connectedDevice = null;
//         });
//         _showSnackBar('Please turn on Bluetooth');
//       }
//     });
//     _subscriptions.add(adapterSub);

//     // Try to turn on Bluetooth
//     if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
//       try {
//         await FlutterBluePlus.turnOn();
//       } catch (e) {
//         print('Could not turn on Bluetooth: $e');
//       }
//     }
//   }

//   // ==================== SCANNING ====================

//   Future<void> _startScan() async {
//     if (_isScanning) return;
//     if (_adapterState != BluetoothAdapterState.on) {
//       _showSnackBar('Bluetooth is off. Please turn it on.');
//       return;
//     }

//     setState(() {
//       _scanResults.clear();
//       _isScanning = true;
//     });

//     // Listen to scan results
//     final scanSub = FlutterBluePlus.onScanResults.listen((results) {
//       setState(() {
//         _scanResults = results;
//       });

//       // Auto-connect to target device if found
//       for (var result in results) {
//         if (result.device.platformName == TARGET_DEVICE_NAME) {
//           print('Found target device: ${result.device.platformName}');
//           _stopScan();
//           _connectToDevice(result.device);
//           break;
//         }
//       }
//     });
//     _subscriptions.add(scanSub);

//     // Auto-cancel scan subscription when scanning stops
//     FlutterBluePlus.cancelWhenScanComplete(scanSub);

//     // Start scanning (10 second timeout)
//     await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

//     // Wait for scanning to stop
//     await FlutterBluePlus.isScanning.where((val) => val == false).first;

//     if (mounted) {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }

//   Future<void> _stopScan() async {
//     await FlutterBluePlus.stopScan();
//     if (mounted) {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }

//   // ==================== CONNECTION ====================

//   Future<void> _connectToDevice(BluetoothDevice device) async {
//     try {
//       await _stopScan();
//       _showSnackBar('Connecting to ${device.platformName}...');

//       final connSub = device.connectionState.listen((state) async {
//         setState(() => _connectionState = state);
//         if (state == BluetoothConnectionState.connected) {
//           _showSnackBar('Connected! Discovering services...');
//           await _discoverServices(device);
//         } else if (state == BluetoothConnectionState.disconnected) {
//           setState(() {
//             _connectedDevice = null;
//             _services = [];
//             _selectedCharacteristic = null;
//             _messages.clear();
//           });
//           _showSnackBar('Disconnected from device');
//         }
//       });

//       device.cancelWhenDisconnected(connSub, delayed: true, next: true);
//       _subscriptions.add(connSub);

//       // Retry logic for timeout
//       int attempts = 0;
//       while (attempts < 3) {
//         try {
//           await device.connect(
//             timeout: const Duration(seconds: 15), // shorter per attempt
//             autoConnect: false,
//           );
//           break; // success
//         } catch (e) {
//           attempts++;
//           if (attempts >= 3) rethrow;
//           _showSnackBar('Retrying connection... ($attempts/3)');
//           await Future.delayed(const Duration(seconds: 2));
//         }
//       }

//       if (mounted) setState(() => _connectedDevice = device);
//     } catch (e) {
//       _showSnackBar('Connection failed after 3 attempts: $e');
//     }
//   }

//   Future<void> _disconnectDevice() async {
//     if (_connectedDevice != null) {
//       await _connectedDevice!.disconnect();
//       setState(() {
//         _connectedDevice = null;
//         _services = [];
//         _selectedCharacteristic = null;
//         _messages.clear();
//       });
//     }
//   }

//   // ==================== SERVICE DISCOVERY ====================

//   Future<void> _discoverServices(BluetoothDevice device) async {
//     try {
//       final services = await device.discoverServices();

//       setState(() {
//         _services = services;
//       });

//       // Find our target characteristic
//       for (var service in services) {
//         if (service.uuid.toString().toLowerCase() ==
//             SERVICE_UUID.toLowerCase()) {
//           for (var char in service.characteristics) {
//             if (char.uuid.toString().toLowerCase() ==
//                 CHARACTERISTIC_UUID.toLowerCase()) {
//               setState(() {
//                 _selectedCharacteristic = char;
//               });
//               await _subscribeToCharacteristic(char);
//               _showSnackBar(
//                 '✓ Characteristic found! Ready to exchange messages.',
//               );
//               return;
//             }
//           }
//         }
//       }

//       // If we get here, show available services for debugging
//       String availableServices = '';
//       for (var service in services) {
//         availableServices += '\n- ${service.uuid}';
//       }
//       _showSnackBar(
//         'Service/Characteristic not found. Available services:$availableServices',
//       );
//     } catch (e) {
//       _showSnackBar('Service discovery failed: $e');
//     }
//   }

//   // ==================== CHARACTERISTIC OPERATIONS ====================

//   Future<void> _subscribeToCharacteristic(
//     BluetoothCharacteristic characteristic,
//   ) async {
//     try {
//       // Listen to value changes (notifications/indications)
//       final valueSub = characteristic.onValueReceived.listen((value) {
//         final message = String.fromCharCodes(value);
//         setState(() {
//           _messages.add({'type': 'received', 'text': message});
//         });
//         _scrollToBottom();
//         _showSnackBar('Received: $message');
//       });

//       if (_connectedDevice != null) {
//         _connectedDevice!.cancelWhenDisconnected(valueSub);
//       }
//       _subscriptions.add(valueSub);

//       // Enable notifications
//       await characteristic.setNotifyValue(true);

//       _showSnackBar('Subscribed to notifications');
//     } catch (e) {
//       _showSnackBar('Subscribe failed: $e');
//     }
//   }

//   Future<void> _sendMessage() async {
//     final text = _messageController.text.trim();
//     if (text.isEmpty) return;
//     if (_selectedCharacteristic == null) {
//       _showSnackBar('No characteristic found. Please reconnect.');
//       return;
//     }

//     try {
//       final bytes = text.codeUnits;
//       await _selectedCharacteristic!.write(bytes, withoutResponse: false);

//       setState(() {
//         _messages.add({'type': 'sent', 'text': text});
//         _messageController.clear();
//       });
//       _scrollToBottom();

//       _showSnackBar('Message sent');
//     } catch (e) {
//       _showSnackBar('Send failed: $e');
//     }
//   }

//   // ==================== HELPER METHODS ====================

//   void _showSnackBar(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
//     );
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   bool get _isConnected =>
//       _connectionState == BluetoothConnectionState.connected;

//   // ==================== UI BUILDERS ====================

//   Widget _buildStatusBar() {
//     Color statusColor;
//     String statusText;

//     if (_adapterState != BluetoothAdapterState.on) {
//       statusColor = Colors.red;
//       statusText = 'Bluetooth OFF';
//     } else if (_isConnected) {
//       statusColor = Colors.green;
//       statusText = 'Connected to ${_connectedDevice?.platformName ?? "Device"}';
//     } else if (_isScanning) {
//       statusColor = Colors.orange;
//       statusText = 'Scanning for devices...';
//     } else {
//       statusColor = Colors.grey;
//       statusText = 'Not connected';
//     }

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       color: statusColor.withOpacity(0.1),
//       child: Row(
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: statusColor,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             statusText,
//             style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
//           ),
//           const Spacer(),
//           if (_isConnected)
//             TextButton(
//               onPressed: _disconnectDevice,
//               style: TextButton.styleFrom(foregroundColor: Colors.red),
//               child: const Text('DISCONNECT'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScanView() {
//     return Column(
//       children: [
//         _buildStatusBar(),
//         Expanded(
//           child: _scanResults.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.bluetooth_searching,
//                         size: 64,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         _isScanning
//                             ? 'Searching for BLE devices...\nMake sure your laptop is advertising'
//                             : 'No devices found.\nTap "Scan" to search for your ESP32',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                       const SizedBox(height: 24),
//                       if (!_isScanning)
//                         ElevatedButton.icon(
//                           onPressed: _startScan,
//                           icon: const Icon(Icons.search),
//                           label: const Text('SCAN FOR DEVICES'),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   itemCount: _scanResults.length,
//                   padding: const EdgeInsets.all(8),
//                   itemBuilder: (context, index) {
//                     final result = _scanResults[index];
//                     final name = result.device.platformName.isNotEmpty
//                         ? result.device.platformName
//                         : 'Unknown Device';
//                     final isTarget = name == TARGET_DEVICE_NAME;

//                     return Card(
//                       elevation: isTarget ? 4 : 1,
//                       color: isTarget ? Colors.green.shade50 : null,
//                       margin: const EdgeInsets.only(bottom: 8),
//                       child: ListTile(
//                         leading: Icon(
//                           Icons.bluetooth,
//                           color: isTarget ? Colors.green : Colors.blue,
//                         ),
//                         title: Text(
//                           name,
//                           style: TextStyle(
//                             fontWeight: isTarget
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                             color: isTarget ? Colors.green.shade800 : null,
//                           ),
//                         ),
//                         subtitle: Text(result.device.remoteId.toString()),
//                         trailing: SizedBox(
//                           height: 60, // constrain the trailing height
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.min, // add this
//                             children: [
//                               Text(
//                                 '${result.rssi} dBm',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: _getRssiColor(result.rssi),
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               ElevatedButton(
//                                 onPressed: () =>
//                                     _connectToDevice(result.device),
//                                 style: ElevatedButton.styleFrom(
//                                   minimumSize: const Size(
//                                     80,
//                                     28,
//                                   ), // slightly smaller
//                                   padding: EdgeInsets.zero,
//                                 ),
//                                 child: const Text(
//                                   'Connect',
//                                   style: TextStyle(fontSize: 12),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         if (!_isScanning && _scanResults.isEmpty)
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: ElevatedButton.icon(
//               onPressed: _startScan,
//               icon: const Icon(Icons.search),
//               label: const Text('SCAN FOR DEVICES'),
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildChatView() {
//     return Column(
//       children: [
//         _buildStatusBar(),
//         Expanded(
//           child: _messages.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.chat_bubble_outline,
//                         size: 64,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'No messages yet.\nType something to send to your ESP32',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.grey.shade600),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = _messages[index];
//                     final isSent = msg['type'] == 'sent';

//                     return Align(
//                       alignment: isSent
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                       child: Container(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSent
//                               ? Colors.blue.shade100
//                               : Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Text(
//                           msg['text'] ?? '',
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             border: Border(top: BorderSide(color: Colors.grey.shade300)),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _messageController,
//                   decoration: InputDecoration(
//                     hintText: 'Type a message...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                   onSubmitted: (_) => _sendMessage(),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               CircleAvatar(
//                 backgroundColor: Colors.blue,
//                 child: IconButton(
//                   icon: const Icon(Icons.send, color: Colors.white, size: 18),
//                   onPressed: _sendMessage,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getRssiColor(int rssi) {
//     if (rssi > -60) return Colors.green;
//     if (rssi > -80) return Colors.orange;
//     return Colors.red;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         actions: [
//           if (_isConnected)
//             IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: _disconnectDevice,
//               tooltip: 'Disconnect',
//             ),
//           if (!_isConnected && _adapterState == BluetoothAdapterState.on)
//             IconButton(
//               icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
//               onPressed: _isScanning ? _stopScan : _startScan,
//               tooltip: _isScanning ? 'Stop Scan' : 'Refresh',
//             ),
//         ],
//       ),
//       body: _isConnected ? _buildChatView() : _buildScanView(),
//     );
//   }
// }
