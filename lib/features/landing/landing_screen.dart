import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/repos/network_config.dart';
import '../../utils/responsive_layout.dart';
import '../device_setup/device_provider.dart';
import 'get_started_provider.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  bool _isLoading = false;

  void _handleGetStarted(GetStartedState getStartedProvider) async {
    setState(() {
      _isLoading = true;
    });
    final res = await NetworkConfig().login();
    if (res.isEmpty) {
      await getStartedProvider.setGetStarted(true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res),
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final size = MediaQuery.of(context).size;
    final isDarkMode = theme.brightness == Brightness.dark;
    final deviceRepository = ref.watch(deviceSetUpProvider.notifier);
    final getStartedProvider = ref.watch(getStartedState.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.35,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.16),
                    colorScheme.primary.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),

          // Thin curved "route line" arcing across the upper half
          Positioned(
            top: size.height * 0.08,
            left: -size.width * 0.1,
            child: SizedBox(
              width: size.width * 1.2,
              height: size.height * 0.3,
              child: CustomPaint(
                painter: _RouteLinePainter(color: colorScheme.primary.withValues(alpha: 0.25)),
              ),
            ),
          ),

          // Thin curved "route line" arcing across the lower half
          Positioned(
            top: size.height * 0.8,
            left: -size.width * 0.2,
            child: SizedBox(
              width: size.width * 1.2,
              height: size.height * 0.3,
              child: CustomPaint(
                painter: _RouteLinePainter(color: colorScheme.primary.withValues(alpha: 0.25)),
              ),
            ),
          ),

          // Small filled circle "stop marker" accent
          Positioned(
            top: size.height * 0.207,
            right: size.width * 0.18,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Bottom-left soft secondary glow for balance
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.10),
                    colorScheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDarkMode ? RadialGradient(
                            colors: [
                              colorScheme.onSurface.withValues(alpha: 0.25),
                              colorScheme.onSurface.withValues(alpha: 0.0),
                            ],
                          ) : null,
                        ),
                        child: Image.asset(
                          'assets/images/canteen_logo.png',
                          width: 150,
                          height: 150,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Canteen Pro',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Pre-order, pick up and\nenjoy your meal.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Primary CTA with gradient fill
                    SizedBox(
                      height: 56,
                      width: ResponsiveLayout.isTablet(context) ? 300 : double.infinity,
                      child: ElevatedButton(
                        onPressed: () async => _handleGetStarted(getStartedProvider),
                        child: _isLoading ? SizedBox(
                          height: 20,
                          width: 20,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ) : Text(
                          'Get Started',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a single gentle curve suggesting a travel route —
/// a quiet nod to the app's domain without being literal.
class _RouteLinePainter extends CustomPainter {
  _RouteLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4, size.height * 0.1,
        size.width * 0.75, size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.9, size.height * 0.6,
        size.width, size.height * 0.35,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RouteLinePainter oldDelegate) => false;
}

