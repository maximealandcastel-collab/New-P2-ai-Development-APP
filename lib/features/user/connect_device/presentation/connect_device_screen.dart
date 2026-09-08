import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/services/health_sync_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// MODEL
// ═══════════════════════════════════════════════════════════════════════════════

enum _DeviceStatus { notConnected, connecting, connected }

class _DeviceItem {
  final String name;
  final String serial;
  _DeviceStatus status;

  _DeviceItem({required this.name, required this.serial, this.status = _DeviceStatus.notConnected});
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

enum _ScreenState {
  initial,       // State 1 — idle, Connect now button
  permission,    // State 2 — permission dialog overlay
  scanning,      // State 3 — no devices found
  found,         // State 4 — device found, not connected
  connected,     // State 5 — device connected
}

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  State<ConnectDeviceScreen> createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen>
    with SingleTickerProviderStateMixin {
  _ScreenState _state = _ScreenState.initial;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  final _DeviceItem _device = _DeviceItem(
    name: 'Fittech  A6',
    serial: 'SN: X59-985-5421',
  );

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Transitions ──────────────────────────────────────────────────────────────
  void _onConnectNow() => setState(() => _state = _ScreenState.permission);

  void _onDenyPermission() => setState(() => _state = _ScreenState.initial);

  void _onAllowPermission() async {
    setState(() => _state = _ScreenState.scanning);
    bool granted = false;
    try {
      granted = await HealthSyncService.instance
          .requestPermissions()
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Health permission timed out. Please try again.'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Health permission could not be completed. Please try again.'),
      ));
    }
    if (!mounted) return;
    setState(() => _state = granted ? _ScreenState.found : _ScreenState.initial);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Health access was denied. You can enable it in Settings.'),
      ));
    }
  }

  void _onConnectDevice() async {
    setState(() => _device.status = _DeviceStatus.connecting);
    String? deviceId;
    Map<String, num>? summary;
    try {
      deviceId = await HealthSyncService.instance
          .pairDevice()
          .timeout(const Duration(seconds: 30));
      if (deviceId != null) {
        summary = await HealthSyncService.instance
            .syncMetrics(days: 7)
            .timeout(const Duration(seconds: 45));
      }
    } catch (_) {
      deviceId = null;
    }
    if (!mounted) return;
    if (deviceId == null) {
      setState(() {
        _device.status = _DeviceStatus.notConnected;
        _state = _ScreenState.found;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not connect. Check your internet and try again.'),
      ));
      return;
    }
    setState(() {
      _device.status = _DeviceStatus.connected;
      _state = _ScreenState.connected;
    });
    if (summary != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Synced: ${summary['steps']} steps, avg HR ${summary['heartRate']}, ${summary['calories']} cal (7 days)'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content
            Column(
              children: [
                _AppBar(),
                Expanded(
                  child: _MainContent(
                    state: _state,
                    pulseAnim: _pulseAnim,
                    device: _device,
                    onConnectNow: _onConnectNow,
                    onConnectDevice: _onConnectDevice,
                  ),
                ),
              ],
            ),

            // ── Permission dialog overlay
            if (_state == _ScreenState.permission)
              _PermissionOverlay(
                onDeny: _onDenyPermission,
                onAllow: _onAllowPermission,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              'Connect device',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.black),
            ),
          ),
          SizedBox(width: 34.w),
        ],
      ),
    );
  }
}

// ─── Main Content ─────────────────────────────────────────────────────────────
class _MainContent extends StatelessWidget {
  final _ScreenState state;
  final Animation<double> pulseAnim;
  final _DeviceItem device;
  final VoidCallback onConnectNow;
  final VoidCallback onConnectDevice;

  const _MainContent({
    required this.state,
    required this.pulseAnim,
    required this.device,
    required this.onConnectNow,
    required this.onConnectDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Hero illustration area
        Expanded(
          child: Center(
            child: _HeroIcon(
              state: state,
              pulseAnim: pulseAnim,
            ),
          ),
        ),

        // ── Text + subtext
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              Text(
                'Connect to your fitness device',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              SizedBox(height: 8.h),
              Text(
                _subtitle(state),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, height: 1.5),
              ),
            ],
          ),
        ),

        SizedBox(height: 28.h),

        // ── Device list (states 3, 4, 5)
        if (state == _ScreenState.scanning ||
            state == _ScreenState.found ||
            state == _ScreenState.connected)
          _DeviceListSection(
            state: state,
            device: device,
            onConnectDevice: onConnectDevice,
          ),

        // ── Connect now button (state 1 only)
        if (state == _ScreenState.initial)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
            child: GestureDetector(
              onTap: onConnectNow,
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  color: BrandColors.of(context).primary,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Connect now',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

        if (state != _ScreenState.initial) SizedBox(height: 32.h),
      ],
    );
  }

  String _subtitle(_ScreenState state) {
    switch (state) {
      case _ScreenState.initial:
        return 'Allow  the app to access your local network. this lets\nto to connect fitness device';
      case _ScreenState.scanning:
        return 'Choose one of the device and tap to connect';
      default:
        return 'Choose one of the device';
    }
  }
}

// ─── Hero Icon ────────────────────────────────────────────────────────────────
class _HeroIcon extends StatelessWidget {
  final _ScreenState state;
  final Animation<double> pulseAnim;

  const _HeroIcon({required this.state, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final isScanning = state == _ScreenState.scanning;

    return ScaleTransition(
      scale: isScanning ? pulseAnim : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 110.w,
        height: 110.w,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          shape: BoxShape.circle,
          boxShadow: isScanning
              ? [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 20, spreadRadius: 6)]
              : [],
        ),
        child: Icon(
          isScanning ? Icons.wifi_tethering : Icons.add,
          size: 44.sp,
          color: Colors.black54,
        ),
      ),
    );
  }
}

// ─── Device List Section ──────────────────────────────────────────────────────
class _DeviceListSection extends StatelessWidget {
  final _ScreenState state;
  final _DeviceItem device;
  final VoidCallback onConnectDevice;

  const _DeviceListSection({
    required this.state,
    required this.device,
    required this.onConnectDevice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available devices',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          SizedBox(height: 12.h),

          // No devices found
          if (state == _ScreenState.scanning)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off_outlined, size: 24.sp, color: Colors.grey.shade400),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No devices found',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                        SizedBox(height: 3.h),
                        Text('Make sure your device is on hte same network\nas your mobile phone.',
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400, height: 1.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Device found / connected
          if (state == _ScreenState.found || state == _ScreenState.connected)
            GestureDetector(
              onTap: device.status == _DeviceStatus.notConnected ? onConnectDevice : null,
              child: _DeviceTile(device: device),
            ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final _DeviceItem device;

  const _DeviceTile({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.watch_outlined, size: 20.sp, color: Colors.black54),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                SizedBox(height: 3.h),
                Text(device.serial,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
              ],
            ),
          ),
          _StatusBadge(status: device.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _DeviceStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _DeviceStatus.connected:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text('Connected',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.white)),
        );

      case _DeviceStatus.connecting:
        return SizedBox(
          width: 18.w,
          height: 18.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: BrandColors.of(context).primary,
          ),
        );

      case _DeviceStatus.notConnected:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text('Not connected',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Colors.black54)),
        );
    }
  }
}

// ─── Permission Dialog Overlay ────────────────────────────────────────────────
class _PermissionOverlay extends StatelessWidget {
  final VoidCallback onDeny;
  final VoidCallback onAllow;

  const _PermissionOverlay({required this.onDeny, required this.onAllow});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed background
        Container(color: Colors.black.withOpacity(0.55)),

        // Dialog
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        Text(
                          'Connect Apple Health',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'P2P FitTech AI will ask Apple Health for access to your steps, heart rate, calories, and workouts. If you continue, approved data can be synced securely to your P2P account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Divider(height: 1, color: Colors.grey.shade200),

                  // Buttons
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onDeny,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              alignment: Alignment.center,
                              child: Text(
                                "Don't Allow",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(width: 1, color: Colors.grey.shade200),
                        Expanded(
                          child: GestureDetector(
                            onTap: onAllow,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              alignment: Alignment.center,
                              child: Text(
                                'Allow',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1565C0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
