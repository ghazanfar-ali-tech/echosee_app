import 'package:echosee_app/app_theme.dart';
import 'package:echosee_app/models/bluetooth_glass_device.dart';
import 'package:echosee_app/models/model.dart';
import 'package:echosee_app/provider/bluetooth_provider.dart';
import 'package:echosee_app/widgets/animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BluetoothTab extends StatelessWidget {
  const BluetoothTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothProvider>(
      builder: (_, btProv, __) {
        return Scaffold(
          appBar: AppBar(title: const Text('EchoSee Glasses')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        FadeSlideIn(child: _GlassesStatusCard(btProv: btProv)),
                        const SizedBox(height: 24),

                        FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: SizedBox(
                            width: double.infinity,
                            child: ScaleTap(
                              onTap: btProv.isScanning
                                  ? btProv.stopScan
                                  : btProv.startScan,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: btProv.isScanning
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.darkCardHover,
                                            AppColors.darkCard,
                                          ],
                                        )
                                      : AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (btProv.isScanning)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.bluetooth_searching_rounded,
                                        color: Colors.white,
                                      ),
                                    const SizedBox(width: 10),
                                    Text(
                                      btProv.isScanning
                                          ? 'Scanning...'
                                          : 'Scan for Glasses',
                                      style: GoogleFonts.rajdhani(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        btProv.discoveredDevices.isEmpty
                            ? _NoDevicesFound(isScanning: btProv.isScanning)
                            : StaggeredList(
                                children: btProv.discoveredDevices.map((
                                  device,
                                ) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _DeviceCard(
                                      device: device,
                                      onConnect: () =>
                                          btProv.connectToDevice(device),
                                      onDisconnect: btProv.disconnect,
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _GlassesStatusCard extends StatelessWidget {
  final BluetoothProvider btProv;
  const _GlassesStatusCard({required this.btProv});

  @override
  Widget build(BuildContext context) {
    final isConnected = btProv.isConnected;
    final device = btProv.connectedDevice;

    return GlowingBorder(
      active: isConnected,
      glowColor: AppColors.success,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (isConnected ? AppColors.success : AppColors.darkBorder)
                    .withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_red_eye_rounded,
                color: isConnected
                    ? AppColors.success
                    : AppColors.darkTextMuted,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected
                        ? (device?.name ?? 'EchoSee Glasses')
                        : 'Not Connected',
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkText,
                    ),
                  ),
                  // Replace the simple subtitle text
                  Text(
                    isConnected && btProv.isVerified
                        ? '✓ Verified  •  ${device?.signalStrength ?? "—"}  •  ${device?.address ?? ""}'
                        : isConnected
                        ? '⏳ Verifying connection...'
                        : 'Tap scan to find your glasses',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isConnected && btProv.isVerified
                          ? AppColors
                                .success // green when verified
                          : AppColors.darkTextMuted, // muted while verifying
                    ),
                  ),
                ],
              ),
            ),
            if (isConnected)
              ScaleTap(
                onTap: btProv.disconnect,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Disconnect',
                    style: GoogleFonts.rajdhani(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final BluetoothGlassesDevice device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _DeviceCard({
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: device.isConnected
              ? AppColors.success.withOpacity(0.4)
              : AppColors.darkBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              device.name.toLowerCase().contains('echosee')
                  ? Icons.remove_red_eye_rounded
                  : Icons.bluetooth_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name == 'Unknown Device'
                      ? 'Unnamed Device'
                      : device.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  device.address,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.darkTextMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  device.signalStrength,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          _SignalBars(bars: device.signalBars),
          const SizedBox(width: 12),
          ScaleTap(
            onTap: device.isConnected ? onDisconnect : onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: device.isConnected
                    ? AppColors.error.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: device.isConnected
                      ? AppColors.error.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Text(
                device.isConnected ? 'Disconnect' : 'Connect',
                style: GoogleFonts.rajdhani(
                  color: device.isConnected
                      ? AppColors.error
                      : AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int bars;
  const _SignalBars({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final active = i < bars;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Container(
            width: 4,
            height: 8.0 + (i * 4),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _NoDevicesFound extends StatelessWidget {
  final bool isScanning;
  const _NoDevicesFound({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isScanning)
            PulseWidget(
              glowColor: AppColors.primary,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.darkCard,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bluetooth_searching_rounded,
                  color: AppColors.primary,
                ),
              ),
            )
          else
            Icon(
              Icons.bluetooth_disabled_rounded,
              size: 56,
              color: AppColors.darkTextMuted,
            ),
          const SizedBox(height: 16),
          Text(
            isScanning ? 'Searching for EchoSee...' : 'No Devices Found',
            style: GoogleFonts.rajdhani(
              fontSize: 18,
              color: AppColors.darkTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
