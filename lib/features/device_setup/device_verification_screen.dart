import 'package:canteen_pro/features/landing/get_started_provider.dart';
import 'package:canteen_pro/network/repos/network_config.dart';
import 'package:canteen_pro/services/device_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/ui_utils.dart';
import '../../utils/responsive_layout.dart';
import 'device_provider.dart';

class DeviceVerificationScreen extends ConsumerStatefulWidget {
  const DeviceVerificationScreen({super.key});

  @override
  ConsumerState<DeviceVerificationScreen> createState() => _DeviceVerificationScreenState();
}

class _DeviceVerificationScreenState extends ConsumerState<DeviceVerificationScreen> {
  bool _isLoading = false;
  bool _isDeviceVerified = false;

  void _verifyDevice() async {
    setState(() => _isLoading = true);
    final deviceSerial = await DeviceInfoService().getDeviceSerialNumber();
    final res = await ref.read(deviceSetUpProvider.notifier)
        .getPhysicalDeviceBySerialNumber(deviceSerial, (device) {
      if (device != null && device.status == 1) {
        setState(() => _isDeviceVerified = true);
      } else {
        setState(() => _isDeviceVerified = false);
        setState(() => _isLoading = false);
        if (mounted) {
          showResultDialog(
            context,
            false,
            title: 'Status',
            message: "Device not verified.\nPlease ensure your admin has verified this device",
          );
        }
      }
    });

    setState(() => _isLoading = false);
    if (res != null) {
      if (mounted) {
        showResultDialog(
          context,
          false,
          title: 'Error',
          message: res.contains("204")
              ? 'Device not found. Please try again.'
              : res,
          onFurtherAction: res.contains("Please login again") ? () async {
            await ref.read(getStartedState.notifier).setGetStarted(false);
            await NetworkConfig().logout();
          } : null
        );
      }
    }
  }

  void _saveDevice() async {
    final devicSetUp = ref.read(deviceSetUpProvider);

    final newDeviceSetUp = devicSetUp?.copyWith(
      status: true,
    );

    await ref.read(deviceSetUpProvider.notifier).saveDeviceSetup(newDeviceSetUp);
    ref.read(deviceSetUpProvider.notifier).setIsDeviceVerified(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final deviceSetUp = ref.watch(deviceSetUpProvider);
    final deviceProvider = ref.watch(deviceSetUpProvider.notifier);
    final isCompact = ResponsiveLayout.getScreenWidth(context) < 900;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(
            'assets/images/device_approval.png',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(.2),
          )),
          Align(
            alignment: Alignment.center,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isCompact ? Icons.phone_android : Icons.tablet,
                          color: colorScheme.primary,
                          size: isCompact ? 30 : 40,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Device Verification',
                          style: textTheme.displayMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isDeviceVerified ? Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: colorScheme.tertiary,
                        size: isCompact ? 40 : 50,
                      ),
                    ) :
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_bottom,
                        color: colorScheme.primary,
                        size: isCompact ? 40 : 50,
                      ).animate(
                          onPlay: (controller) => controller.repeat(),
                          onComplete: (controller) => controller.repeat(),
                          effects:  [
                            RotateEffect(
                              begin: 0,
                              end: 360,
                              curve: Curves.linear,
                              duration: const Duration(seconds: 550),
                            )
                          ]
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isDeviceVerified ? 'Device Verified' : 'Please wait for admin to verify device',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: ResponsiveLayout.getCardWidth(context),
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? () {} :
                        _isDeviceVerified ? _saveDevice : _verifyDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLoading || _isDeviceVerified
                              ? colorScheme.tertiary : colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: _isLoading ?
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:  [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('Verifying device...', style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold))
                            ]
                        ): Text(
                            _isDeviceVerified ? 'Continue' : 'Check Status', style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold
                        )),
                      ),
                    ),
                  ]
                ),
              ),
            )
          )
        ],
      ),
    );
  }
}