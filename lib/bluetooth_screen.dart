import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart' as classic;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum BtTabType { classic, ble }

enum ConnectionStatus { disconnected, connecting, connected }

// ─── Unified Device Model ─────────────────────────────────────────────────────

class UnifiedDevice {
  final String name;
  final String address;
  final BtTabType type;
  final classic.Device? classicDevice;
  final ble.BluetoothDevice? bleDevice;

  UnifiedDevice.fromClassic(classic.Device d)
    : name = d.name ?? 'Unknown Device',
      address = d.address,
      type = BtTabType.classic,
      classicDevice = d,
      bleDevice = null;

  UnifiedDevice.fromBle(ble.BluetoothDevice d)
    : name = d.platformName.isNotEmpty ? d.platformName : 'Unknown BLE Device',
      address = d.remoteId.str,
      type = BtTabType.ble,
      classicDevice = null,
      bleDevice = d;
}

// ─── Home Page ────────────────────────────────────────────────────────────────

class BluetoothHomePage extends StatefulWidget {
  const BluetoothHomePage({super.key});

  @override
  State<BluetoothHomePage> createState() => _BluetoothHomePageState();
}

class _BluetoothHomePageState extends State<BluetoothHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ── Speech & TTS ──
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _sttAvailable = false;

  /// Which tab is currently recording: 0 = classic, 1 = ble, null = none
  int? _recordingTab;

  /// Live transcript shown while recording
  String _liveTranscript = '';

  // ── Classic Bluetooth ──
  final BluetoothClassic _classicPlugin = BluetoothClassic();
  List<UnifiedDevice> _classicDevices = [];
  List<UnifiedDevice> _pairedDevices = [];
  bool _classicScanning = false;
  UnifiedDevice? _connectedClassicDevice;
  ConnectionStatus _classicStatus = ConnectionStatus.disconnected;
  final List<String> _classicLog = [];
  StreamSubscription? _classicDataSub;
  Uint8List _classicData = Uint8List(0);
  bool _classicListenerAttached = false;

  // ── BLE ──
  static const String _serviceUUID = "12345678-1234-1234-1234-123456789abc";
  static const String _charUUID = "abcdefab-1234-5678-1234-abcdefabcdef";

  List<UnifiedDevice> _bleDevices = [];
  bool _bleScanning = false;
  UnifiedDevice? _connectedBleDevice;
  ConnectionStatus _bleStatus = ConnectionStatus.disconnected;
  final List<String> _bleLog = [];
  StreamSubscription? _bleScanSub;
  StreamSubscription? _bleConnectionSub;
  List<ble.BluetoothService> _bleServices = [];
  ble.BluetoothCharacteristic? _txCharacteristic;
  ble.BluetoothCharacteristic? _rxCharacteristic;
  final List<String> _bleReceivedData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initClassic();
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _classicDataSub?.cancel();
    _bleScanSub?.cancel();
    _bleConnectionSub?.cancel();
    _stt.cancel();
    _tts.stop();
    super.dispose();
  }

  // ─── Speech Init ──────────────────────────────────────────────────────────

  Future<void> _initSpeech() async {
    _sttAvailable = await _stt.initialize(
      onError: (e) => debugPrint('STT error: $e'),
      onStatus: (s) {
        // When listening stops (e.g. silence), finalise and send
        if (s == SpeechToText.doneStatus && _recordingTab != null) {
          _onSpeechDone();
        }
      },
    );
    setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  // ─── Speech Recording ─────────────────────────────────────────────────────

  /// Start recording for the given tab index (0 = classic, 1 = ble)
  Future<void> _startRecording(int tabIndex) async {
    if (!_sttAvailable) {
      _showErrorSnackbar('Microphone not available. Check permissions.');
      return;
    }
    if (_recordingTab != null) {
      await _stopRecording();
      return;
    }

    setState(() {
      _recordingTab = tabIndex;
      _liveTranscript = '';
    });

    await _stt.listen(
      onResult: (result) {
        setState(() => _liveTranscript = result.recognizedWords);
        // Auto-send when a final result arrives
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _onSpeechDone();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopRecording() async {
    await _stt.stop();
    _onSpeechDone();
  }

  void _onSpeechDone() {
    final text = _liveTranscript.trim();
    final tab = _recordingTab;

    setState(() {
      _recordingTab = null;
      _liveTranscript = '';
    });

    if (text.isEmpty || tab == null) return;

    if (tab == 0) {
      _sendClassicData(text);
    } else {
      _sendBleData(text);
    }
  }

  // ─── TTS Playback ─────────────────────────────────────────────────────────

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  // ─── Classic Methods ──────────────────────────────────────────────────────

  Future<void> _initClassic() async {
    try {
      await _classicPlugin.initPermissions();
      await _loadPairedDevices();
    } catch (e) {
      _addClassicLog('Permission error: $e');
    }
  }

  Future<void> _loadPairedDevices() async {
    try {
      final paired = await _classicPlugin.getPairedDevices();
      if (!mounted) return;
      setState(() {
        _pairedDevices = paired
            .map((d) => UnifiedDevice.fromClassic(d))
            .toList();
      });
      _addClassicLog('Found ${_pairedDevices.length} paired device(s)');
    } catch (e) {
      _addClassicLog('Error loading paired devices: $e');
    }
  }

  Future<void> _startClassicScan() async {
    setState(() {
      _classicDevices = [];
      _classicScanning = true;
    });
    _addClassicLog('Scanning for Classic devices...');

    if (!_classicListenerAttached) {
      _classicListenerAttached = true;
      _classicPlugin.onDeviceDiscovered().listen((event) {
        final unified = UnifiedDevice.fromClassic(event);
        if (!mounted) return;
        setState(() {
          if (!_classicDevices.any((d) => d.address == unified.address)) {
            _classicDevices.add(unified);
          }
        });
        _addClassicLog('Found: ${unified.name} (${unified.address})');
      });
    }

    await _classicPlugin.startScan();

    Future.delayed(const Duration(seconds: 15), () {
      if (_classicScanning && mounted) _stopClassicScan();
    });
  }

  Future<void> _stopClassicScan() async {
    await _classicPlugin.stopScan();
    if (!mounted) return;
    setState(() => _classicScanning = false);
    _addClassicLog('Scan stopped');
  }

  Future<void> _connectClassic(UnifiedDevice device) async {
    if (_classicStatus == ConnectionStatus.connected) {
      await _disconnectClassic();
      return;
    }

    if (!mounted) return;
    setState(() => _classicStatus = ConnectionStatus.connecting);
    _addClassicLog('Connecting to ${device.name}...');

    try {
      await _classicDataSub?.cancel();
      _classicDataSub = null;

      await _classicPlugin.connect(
        device.address,
        "00001101-0000-1000-8000-00805f9b34fb",
      );

      if (!mounted) return;
      setState(() {
        _connectedClassicDevice = device;
        _classicStatus = ConnectionStatus.connected;
        _classicData = Uint8List(0);
      });
      _addClassicLog('Connected to ${device.name}');

      _classicDataSub = _classicPlugin.onDeviceDataReceived().listen(
        (data) {
          if (!mounted) return;
          setState(() {
            _classicData = Uint8List.fromList([..._classicData, ...data]);
          });
          final text = String.fromCharCodes(data).trim();
          _addClassicLog('Received: $text');
          // 🔊 Speak received text aloud
          if (text.isNotEmpty) _speak(text);
        },
        onError: (e) {
          _addClassicLog('Data stream error: $e');
          if (mounted) {
            setState(() {
              _classicStatus = ConnectionStatus.disconnected;
              _connectedClassicDevice = null;
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _classicStatus = ConnectionStatus.disconnected);

      final errorMsg = e.toString();
      if (errorMsg.contains('bonding') || errorMsg.contains('pair')) {
        _addClassicLog('Device not paired. Pair in Android Settings first.');
        _showPairingDialog(device);
      } else if (errorMsg.contains('already connected')) {
        _addClassicLog('Already connected. Disconnect first.');
      } else if (errorMsg.contains('permission')) {
        _addClassicLog('Permission denied.');
      } else {
        _addClassicLog('Connection failed: $errorMsg');
      }
    }
  }

  Future<void> _disconnectClassic() async {
    try {
      await _classicPlugin.disconnect();
    } catch (_) {}
    await _classicDataSub?.cancel();
    _classicDataSub = null;
    if (!mounted) return;
    setState(() {
      _connectedClassicDevice = null;
      _classicStatus = ConnectionStatus.disconnected;
      _classicData = Uint8List(0);
    });
    _addClassicLog('Disconnected');
  }

  Future<void> _sendClassicData(String text) async {
    if (_classicStatus != ConnectionStatus.connected) return;
    try {
      await _classicPlugin.write(text);
      _addClassicLog('Sent: $text');
    } catch (e) {
      _addClassicLog('Send error: $e');
    }
  }

  void _addClassicLog(String msg) {
    if (!mounted) return;
    setState(() {
      _classicLog.insert(0, '[${_timestamp()}] $msg');
      if (_classicLog.length > 50) _classicLog.removeLast();
    });
  }

  // ─── BLE Methods ──────────────────────────────────────────────────────────

  Future<void> _startBleScan() async {
    await _bleScanSub?.cancel();
    _bleScanSub = null;

    setState(() {
      _bleDevices = [];
      _bleScanning = true;
    });
    _addBleLog('Scanning for BLE devices...');

    try {
      await ble.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      _bleScanSub = ble.FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        setState(() {
          _bleDevices = results
              .where((r) => r.device.platformName.isNotEmpty)
              .map((r) => UnifiedDevice.fromBle(r.device))
              .toList();
        });
      });

      ble.FlutterBluePlus.isScanning.listen((scanning) {
        if (!scanning && _bleScanning && mounted) {
          setState(() => _bleScanning = false);
          _addBleLog('Scan complete. Found ${_bleDevices.length} device(s)');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _bleScanning = false);
      _addBleLog('Scan error: $e');
    }
  }

  Future<void> _stopBleScan() async {
    await ble.FlutterBluePlus.stopScan();
    if (!mounted) return;
    setState(() => _bleScanning = false);
    _addBleLog('Scan stopped');
  }

  Future<void> _connectBle(UnifiedDevice device) async {
    if (_bleStatus == ConnectionStatus.connected) {
      await _disconnectBle();
      return;
    }
    if (device.bleDevice == null) return;

    setState(() => _bleStatus = ConnectionStatus.connecting);
    _addBleLog('Connecting to ${device.name}...');

    try {
      await device.bleDevice!.connect(
        autoConnect: false,
        timeout: const Duration(seconds: 10),
      );

      if (!mounted) return;
      setState(() {
        _connectedBleDevice = device;
        _bleStatus = ConnectionStatus.connected;
      });
      _addBleLog('Connected to ${device.name}');

      _bleConnectionSub = device.bleDevice!.connectionState.listen((state) {
        if (state == ble.BluetoothConnectionState.disconnected) {
          if (!mounted) return;
          setState(() {
            _bleStatus = ConnectionStatus.disconnected;
            _connectedBleDevice = null;
            _bleServices = [];
            _txCharacteristic = null;
            _rxCharacteristic = null;
          });
          _addBleLog('Device disconnected');
        }
      });

      final services = await device.bleDevice!.discoverServices();
      if (!mounted) return;
      setState(() => _bleServices = services);
      _addBleLog('Discovered ${services.length} service(s)');

      bool nordicFound = false;
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() ==
            _serviceUUID.toLowerCase()) {
          nordicFound = true;
          _addBleLog('✅ Nordic UART Service found');

          for (final char in service.characteristics) {
            final uuid = char.uuid.toString().toLowerCase();

            if (uuid == _charUUID.toLowerCase()) {
              _rxCharacteristic = char;
              _txCharacteristic = char;
              await char.setNotifyValue(true);
              char.lastValueStream.listen((value) {
                if (value.isEmpty || !mounted) return;
                final text = String.fromCharCodes(value).trim();
                setState(() {
                  _bleReceivedData.insert(0, '[${_timestamp()}] ← $text');
                  if (_bleReceivedData.length > 50)
                    _bleReceivedData.removeLast();
                });
                _addBleLog('Received: $text');
                // 🔊 Speak received text aloud
                if (text.isNotEmpty) _speak(text);
              });
              _addBleLog('✅ TX ready (notifications on)');
            }
          }
          break;
        }
      }

      if (!nordicFound) {
        _addBleLog('ℹ️ Nordic UART not found — generic BLE device');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _bleStatus = ConnectionStatus.disconnected);

      final errorMsg = e.toString();
      if (errorMsg.contains('timeout') || errorMsg.contains('147')) {
        _addBleLog('❌ Timeout — not a BLE peripheral or out of range');
        _showErrorSnackbar('${device.name} timed out. Not a BLE peripheral?');
      }
    }
  }

  Future<void> _disconnectBle() async {
    try {
      await _connectedBleDevice?.bleDevice?.disconnect();
    } catch (_) {}
    await _bleConnectionSub?.cancel();
    _bleConnectionSub = null;
    if (!mounted) return;
    setState(() {
      _connectedBleDevice = null;
      _bleStatus = ConnectionStatus.disconnected;
      _bleServices = [];
      _txCharacteristic = null;
      _rxCharacteristic = null;
    });
    _addBleLog('Disconnected');
  }

  Future<void> _sendBleData(String text) async {
    if (_rxCharacteristic == null) {
      _addBleLog('❌ No writable characteristic found');
      _showErrorSnackbar('This device does not support sending data');
      return;
    }
    try {
      await _rxCharacteristic!.write(text.codeUnits, withoutResponse: false);
      _addBleLog('Sent: $text');
    } catch (e) {
      _addBleLog('Send error: $e');
    }
  }

  void _addBleLog(String msg) {
    if (!mounted) return;
    setState(() {
      _bleLog.insert(0, '[${_timestamp()}] $msg');
      if (_bleLog.length > 50) _bleLog.removeLast();
    });
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _timestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showPairingDialog(UnifiedDevice device) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Pairing Required',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        content: Text(
          '${device.name} is not paired.\n\nGo to:\nAndroid Settings → Bluetooth → pair "${device.name}"\n\nThen try connecting again.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ),
              ),
              child: Icon(
                Icons.bluetooth,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Bluetooth Manager',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: 3,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.blue.withAlpha(150),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bluetooth, size: 16),
                  const SizedBox(width: 6),
                  const Text('Classic BT'),
                  if (_classicStatus == ConnectionStatus.connected) ...[
                    const SizedBox(width: 6),
                    _statusDot(Colors.greenAccent),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bluetooth_searching, size: 16),
                  const SizedBox(width: 6),
                  const Text('BLE'),
                  if (_bleStatus == ConnectionStatus.connected) ...[
                    const SizedBox(width: 6),
                    _statusDot(
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.greenAccent
                          : Colors.green,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildClassicTab(), _buildBleTab()],
      ),
    );
  }

  Widget _statusDot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // ─── Classic Tab ──────────────────────────────────────────────────────────

  Widget _buildClassicTab() {
    return Column(
      children: [
        if (_classicStatus != ConnectionStatus.disconnected)
          _buildStatusBanner(
            _connectedClassicDevice?.name ?? '',
            _classicStatus,
            onDisconnect: _disconnectClassic,
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.devices,
                  label: 'Paired Devices',
                  onTap: _loadPairedDevices,
                  color: Colors.blue.withAlpha(100),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: _classicScanning ? Icons.stop : Icons.radar,
                  label: _classicScanning ? 'Stop Scan' : 'Scan Devices',
                  onTap: _classicScanning
                      ? _stopClassicScan
                      : _startClassicScan,
                  color: _classicScanning
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.redAccent
                            : Colors.red)
                      : Theme.of(context).colorScheme.primary,
                  isLoading: _classicScanning,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (_pairedDevices.isNotEmpty) ...[
                _sectionHeader(
                  'Paired Devices',
                  Icons.link,
                  _pairedDevices.length,
                ),
                ..._pairedDevices.map(
                  (d) => _buildDeviceCard(
                    d,
                    isPaired: true,
                    isConnected: _connectedClassicDevice?.address == d.address,
                    onTap: () => _connectClassic(d),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_classicDevices.isNotEmpty) ...[
                ..._classicDevices.map(
                  (d) => _buildDeviceCard(
                    d,
                    isPaired: false,
                    isConnected: _connectedClassicDevice?.address == d.address,
                    onTap: () => _connectClassic(d),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_classicLog.isNotEmpty) ...[
                _sectionHeader(
                  'Activity Log',
                  Icons.terminal,
                  _classicLog.length,
                ),
                _buildLogBox(_classicLog),
              ],
            ],
          ),
        ),
        if (_classicStatus == ConnectionStatus.connected)
          _buildSendBox(tabIndex: 0, onSend: _sendClassicData),
      ],
    );
  }

  // ─── BLE Tab ──────────────────────────────────────────────────────────────

  Widget _buildBleTab() {
    return Column(
      children: [
        if (_bleStatus != ConnectionStatus.disconnected)
          _buildStatusBanner(
            _connectedBleDevice?.name ?? '',
            _bleStatus,
            onDisconnect: _disconnectBle,
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildActionButton(
            icon: _bleScanning ? Icons.stop : Icons.bluetooth_searching,
            label: _bleScanning ? 'Stop Scanning' : 'Scan BLE Devices',
            onTap: _bleScanning ? _stopBleScan : _startBleScan,
            color: _bleScanning
                ? const Color.fromARGB(255, 31, 28, 28)
                : const Color(0xFF00C2A8),
            isLoading: _bleScanning,
            fullWidth: true,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (_bleDevices.isNotEmpty) ...[
                _sectionHeader(
                  'BLE Devices',
                  Icons.bluetooth_searching,
                  _bleDevices.length,
                ),
                ..._bleDevices.map(
                  (d) => _buildDeviceCard(
                    d,
                    isPaired: false,
                    isConnected: _connectedBleDevice?.address == d.address,
                    onTap: () => _connectBle(d),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (_bleServices.isNotEmpty) ...[
                _sectionHeader(
                  'Services',
                  Icons.miscellaneous_services,
                  _bleServices.length,
                ),
                ..._bleServices.map((s) => _buildServiceCard(s)),
                const SizedBox(height: 8),
              ],
              if (_bleReceivedData.isNotEmpty) ...[
                _sectionHeader(
                  'Received Data',
                  Icons.download,
                  _bleReceivedData.length,
                ),
                _buildLogBox(_bleReceivedData),
                const SizedBox(height: 8),
              ],
              if (_bleLog.isNotEmpty) ...[
                _sectionHeader('Activity Log', Icons.terminal, _bleLog.length),
                _buildLogBox(_bleLog),
              ],
            ],
          ),
        ),
        if (_bleStatus == ConnectionStatus.connected)
          _buildSendBox(tabIndex: 1, onSend: _sendBleData),
      ],
    );
  }

  // ─── Shared Widgets ───────────────────────────────────────────────────────

  Widget _buildStatusBanner(
    String deviceName,
    ConnectionStatus status, {
    required VoidCallback onDisconnect,
  }) {
    final isConnecting = status == ConnectionStatus.connecting;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isConnecting
            ? Theme.of(context).colorScheme.tertiary.withOpacity(0.12)
            : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnecting
              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.4)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          if (isConnecting)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            )
          else
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isConnecting
                  ? 'Connecting to $deviceName...'
                  : 'Connected: $deviceName',
              style: TextStyle(
                color: isConnecting
                    ? Theme.of(context).colorScheme.tertiary
                    : Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (!isConnecting)
            GestureDetector(
              onTap: onDisconnect,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  'Disconnect',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    UnifiedDevice device, {
    required bool isPaired,
    required bool isConnected,
    required VoidCallback onTap,
  }) {
    IconData deviceIcon = Icons.devices_other;
    final name = device.name.toLowerCase();
    if (name.contains('earbud') ||
        name.contains('earphone') ||
        name.contains('airpod') ||
        name.contains('buds')) {
      deviceIcon = Icons.earbuds;
    } else if (name.contains('headphone') || name.contains('headset')) {
      deviceIcon = Icons.headphones;
    } else if (name.contains('esp') || name.contains('arduino')) {
      deviceIcon = Icons.developer_board;
    } else if (name.contains('laptop') ||
        name.contains('macbook') ||
        name.contains('computer') ||
        name.contains('pc')) {
      deviceIcon = Icons.laptop;
    } else if (name.contains('phone') ||
        name.contains('iphone') ||
        name.contains('samsung') ||
        name.contains('pixel')) {
      deviceIcon = Icons.smartphone;
    } else if (name.contains('speaker') || name.contains('soundbar')) {
      deviceIcon = Icons.speaker;
    } else if (name.contains('watch')) {
      deviceIcon = Icons.watch;
    } else if (name.contains('keyboard')) {
      deviceIcon = Icons.keyboard;
    } else if (name.contains('mouse')) {
      deviceIcon = Icons.mouse;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isConnected
              ? (isDark ? const Color(0xFF1A2A2E) : const Color(0xFFE8FFF4))
              : (isDark ? const Color(0xFF1A1A2E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isConnected
                ? (isDark
                      ? const Color(0xFF00C853).withOpacity(0.4)
                      : const Color(0xFF00C853).withOpacity(0.3))
                : (isDark
                      ? const Color(0xFF7B61FF).withOpacity(0.3)
                      : const Color(0xFF7B61FF).withOpacity(0.15)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                deviceIcon,
                color: isConnected
                    ? (isDark ? Colors.greenAccent : const Color(0xFF00C853))
                    : (isDark
                          ? const Color(0xFF9D8FFF)
                          : const Color(0xFF7B61FF)),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    device.address,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isPaired)
                  _badge('Paired', Theme.of(context).colorScheme.secondary),
                if (isConnected)
                  _badge('Connected', Theme.of(context).colorScheme.secondary),
                if (!isPaired && !isConnected)
                  _badge('Unpaired', Theme.of(context).colorScheme.secondary),
                const SizedBox(height: 4),
                Icon(
                  isConnected ? Icons.link_off : Icons.link,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildServiceCard(ble.BluetoothService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.miscellaneous_services,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  service.uuid.toString().toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _badge(
                '${service.characteristics.length} chars',
                Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          if (service.characteristics.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...service.characteristics
                .take(3)
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_right,
                          size: 12,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            c.uuid.toString().toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            if (c.properties.read)
                              _badge(
                                'R',
                                Theme.of(context).colorScheme.secondary,
                              ),
                            const SizedBox(width: 3),
                            if (c.properties.write)
                              _badge(
                                'W',
                                Theme.of(context).colorScheme.secondary,
                              ),
                            const SizedBox(width: 3),
                            if (c.properties.notify)
                              _badge(
                                'N',
                                Theme.of(context).colorScheme.secondary,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            if (service.characteristics.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 28),
                child: Text(
                  '+${service.characteristics.length - 3} more',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogBox(List<String> log) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: log.length,
        itemBuilder: (context, i) => Text(
          log[i],
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // ─── Send Box with Voice Button ───────────────────────────────────────────

  /// [tabIndex] 0 = classic, 1 = ble
  Widget _buildSendBox({
    required int tabIndex,
    required Function(String) onSend,
  }) {
    final controller = TextEditingController();
    final isRecording = _recordingTab == tabIndex;
    final micColor = isRecording
        ? Colors.redAccent
        : Theme.of(context).colorScheme.primary;

    return StatefulBuilder(
      builder: (context, setLocal) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            border: Border(
              top: BorderSide(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Live transcript preview while recording
              if (isRecording && _liveTranscript.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '🎙 $_liveTranscript',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              Row(
                children: [
                  // ── Mic button ──
                  GestureDetector(
                    onTap: () async {
                      if (isRecording) {
                        await _stopRecording();
                      } else {
                        await _startRecording(tabIndex);
                      }
                      // Rebuild to reflect state
                      if (mounted) setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: micColor.withOpacity(isRecording ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: micColor.withOpacity(0.5)),
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: micColor,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Text field ──
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: isRecording
                            ? 'Listening...'
                            : 'Type or tap mic to speak...',
                        hintStyle: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 13,
                          fontStyle: isRecording
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Send button ──
                  GestureDetector(
                    onTap: () {
                      if (controller.text.isNotEmpty) {
                        onSend(controller.text);
                        controller.clear();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
