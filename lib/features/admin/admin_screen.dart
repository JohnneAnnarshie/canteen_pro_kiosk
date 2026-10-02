import 'package:canteen_pro/core/router/app_router.dart';
import 'package:canteen_pro/core/theme/app_theme.dart';
import 'package:canteen_pro/features/device_setup/device_provider.dart';
import 'package:canteen_pro/models/canteen_setting.dart';
import 'package:canteen_pro/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/meal_time.dart';
import '../../network/repos/network_config.dart';
import '../../shared/widgets/ui_utils.dart';
import '../landing/get_started_provider.dart';
import 'configuration_proivder.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  bool _isStartUp = false;
  CanteenSetting? _selectedCanteenSetting;
  MealTime? _selectedMealTime;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConfigStatus();
    });
  }

  void _checkConfigStatus() async {
    final config = ref.read(configurationState);
    if (config.canteenSetting == null && config.mealServeTime == null) {
      if (!_isStartUp) {
       setState(() {
         _isStartUp = true;
       });
       await Future.delayed(const Duration(seconds: 2));
       await _selectCanteenLocation();
       await _selectServeTime();
      }
    }
  }

  void _showAppLoader() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black.withAlpha(130),
          child: const Center(child: AppLoader())),
    );
  }

  void _processResult(String? res, { Function()? onAlternateAction }) {
    if (res != null) {
      final isNotFound = res.contains("204");
      if (mounted) {
        showResultDialog(
          context,
          false,
          title: 'Error',
          message: isNotFound ? "No resource found" : res,
          onFurtherAction: res.contains("Please login again") ? () async {
            await ref.read(getStartedState.notifier).setGetStarted(false);
            await NetworkConfig().logout();
          } : null,
        );
      }
      return;
    } else {
      onAlternateAction?.call();
      return;
    }
  }


  Future<List<CanteenSetting>?> _fetchAvailableCanteenSettings() async {
    try {
      _showAppLoader();
      final res = await MealRosterRepository().getCanteenSettings(page: 1);
      if (!mounted) return res.items;
      Navigator.pop(context);
      return res.items;
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      _processResult(e.toString());
      return null;
    }
  }

  Future<List<MealTime>?> _fetchAvailableMealTimes() async {
    try {
      _showAppLoader();
      final res = await MealRepository().fetchMealTimes(page: 1);
      if (!mounted) return res.items;
      Navigator.pop(context);
      return res.items;
    } catch (e) {
      if (mounted) {
      Navigator.pop(context);
      }
      _processResult(e.toString());
      return null;
    }
  }

  Future<void> _selectCanteenLocation() async {
    final canteenSettings = await _fetchAvailableCanteenSettings();
    if (canteenSettings == null) return;
    if (!mounted) return;
    final result = await SelectionBottomSheet.show<CanteenSetting>(
      context,
      title: 'Select Canteen Location',
      items: canteenSettings,
      itemLabel: (setting) => setting.name,
      initialSelected: [],
      multiSelect: false,
      onRefresh: () async {
        final refreshedSettings = await _fetchAvailableCanteenSettings();
        if (refreshedSettings == null) return [];
        return refreshedSettings;
      },
    );

    if (result != null && result.isNotEmpty) {
      if (_isStartUp) {
        _selectedCanteenSetting = result.first;
        return;
      }
      final configuration = ref.read(configurationState);
      ref.read(configurationState.notifier)
          .saveConfiguration(configuration.copyWith(canteenSetting: result.first));
    }
  }

  Future<void> _selectServeTime() async {
    final mealTimes = await _fetchAvailableMealTimes();
    if (mealTimes == null) return;
    if (!mounted) return;
    final result = await SelectionBottomSheet.show<MealTime>(
      context,
      title: 'Select meal time',
      items: mealTimes,
      itemLabel: (mealTime) => mealTime.name,
      initialSelected: [],
      multiSelect: false,
      onRefresh: () async {
        final refreshedMealTimes = await _fetchAvailableMealTimes();
        if (refreshedMealTimes == null) return [];
        return refreshedMealTimes;
      },
    );

    if (result != null && result.isNotEmpty) {
      if (_isStartUp) {
        _selectedMealTime = result.first;
        return;
      }
      final configuration = ref.read(configurationState);
      ref.read(configurationState.notifier)
          .saveConfiguration(configuration.copyWith(mealServeTime: result.first));
    }
  }

  Future<void> _resetDevice() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.restart_alt_rounded, color: Theme.of(context).colorScheme.error),
        title: const Text('Reset this device?'),
        content: const Text(
          'This removes the saved device setup and returns the app to device configuration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset device'),
          ),
        ],
      ),
    );
    if (shouldReset != true || !mounted) return;
    await ref.read(deviceSetUpProvider.notifier).saveDeviceSetup(null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUnavailable(String feature) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text(
          'This action is not connected in the current app version.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSound(bool value) async {
    final configProvider = ref.read(configurationState.notifier);
    final configuration = ref.read(configurationState);
    await configProvider.saveConfiguration(configuration.copyWith(soundEnabled: value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final deviceSetup = ref.watch(deviceSetUpProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;
    final configuration = ref.watch(configurationState);
    final configProvider = ref.watch(configurationState.notifier);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: colors.onPrimary,
          automaticallyImplyLeading: true,
          leading: _isStartUp ? null : IconButton(
            onPressed: () => context.pop(true),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Administrator',
            style: textTheme.titleLarge?.copyWith(color: colors.onPrimary),
          ),
          actions: _isStartUp ? [
            FilledButton.icon(
                onPressed: (_selectedCanteenSetting == null
                    || _selectedMealTime == null) ?
                    () async {
                  await configProvider.saveConfiguration(
                    configuration.copyWith(
                      canteenSetting: _selectedCanteenSetting,
                      mealServeTime: _selectedMealTime
                    )
                  );
                } : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.tertiary,
                  foregroundColor: colors.onTertiary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ),
                icon: Icon(Icons.check, color: colors.onTertiary),
                label: Text(
                  'Complete Set Up',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                )
            )
          ] : null,
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: ListView(
                padding: EdgeInsets.fromLTRB(isWide ? 32 : 18, 24, isWide ? 32 : 18, 40),
                children: [
                  _AdminWelcomeCard(
                    deviceName: deviceSetup?.deviceName,
                    deviceType: deviceSetup?.deviceType,
                    textTheme: textTheme,
                    colors: colors,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: 'QUICK ACTIONS', textTheme: textTheme, colors: colors),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: isWide ? 4.8 : 2.7,
                        children: [
                          _ActionCard(
                            icon: Icons.person_add_alt_1_rounded,
                            title: 'Enroll user',
                            subtitle: 'Register a new user on this device',
                            colors: colors,
                            textTheme: textTheme,
                            onTap: () => context.push(AppRoute.userEnrollment.path),
                          ),
                          _ActionCard(
                            icon: Icons.sync_rounded,
                            title: 'Sync data',
                            subtitle: 'Push and pull data with the server',
                            colors: colors,
                            textTheme: textTheme,
                            onTap: () => _showUnavailable('Sync data'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: 'DEVICE SETTINGS', textTheme: textTheme, colors: colors),
                  const SizedBox(height: 12),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: LucideIcons.clock,
                          title: 'Serve time',
                          subtitle: deviceSetup?.deviceType.isNotEmpty == true
                              ? deviceSetup!.deviceType
                              : 'Set serve time',
                          colors: colors,
                          textTheme: textTheme,
                          onTap: () => _selectServeTime(),
                        ),
                        _SettingsDivider(colors: colors),
                        _SettingsTile(
                          icon: Icons.location_on_outlined,
                          title: 'Canteen location',
                          subtitle: configuration.canteenSetting?.name ?? "Not Set",
                          colors: colors,
                          textTheme: textTheme,
                          onTap: _selectCanteenLocation,
                        ),
                        _SettingsDivider(colors: colors),
                        _SettingsTile(
                          icon: Icons.volume_up_outlined,
                          title: 'Sound',
                          subtitle: configuration.soundEnabled ? "Enabled" : "Disabled",
                          colors: colors,
                          textTheme: textTheme,
                          onTap: () async
                          => await _toggleSound(!configuration.soundEnabled),
                          trailing: Switch(
                            value: configuration.soundEnabled,
                            onChanged: (value) async => await _toggleSound(value),
                          ),
                        ),
                        _SettingsDivider(colors: colors),
                        _SettingsTile(
                          icon: Icons.lock_open_rounded,
                          title: 'Disable kiosk mode',
                          subtitle: configuration.kioskMode ? "Enabled" : "Disabled",
                          colors: colors,
                          textTheme: textTheme,
                          onTap: () => _showUnavailable('Kiosk mode'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(label: 'ADVANCED', textTheme: textTheme, colors: colors),
                  const SizedBox(height: 12),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.restart_alt_rounded,
                          title: 'Reset device',
                          subtitle: 'Remove saved device setup and start again',
                          colors: colors,
                          textTheme: textTheme,
                          destructive: true,
                          onTap: _resetDevice,
                        ),
                        _SettingsDivider(colors: colors),
                        _SettingsTile(
                          icon: Icons.logout_rounded,
                          title: 'Log Out',
                          subtitle: 'Sign out of admin account',
                          colors: colors,
                          textTheme: textTheme,
                          destructive: true,
                          onTap: _resetDevice,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminWelcomeCard extends StatelessWidget {
  const _AdminWelcomeCard({
    required this.deviceName,
    required this.deviceType,
    required this.textTheme,
    required this.colors,
  });

  final String? deviceName;
  final String? deviceType;
  final TextTheme textTheme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final label = (deviceName?.trim().isNotEmpty == true)
        ? deviceName!
        : 'Device administration';
    final type = deviceType?.trim().isNotEmpty == true
        ? deviceType!.toUpperCase()
        : 'DEVICE SETUP REQUIRED';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.onPrimary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.admin_panel_settings_rounded, color: colors.onPrimary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Manage enrollment and device preferences',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 520) ...[
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                type,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onPrimary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    required this.textTheme,
    required this.colors,
  });

  final String label;
  final TextTheme textTheme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: textTheme.labelMedium?.copyWith(
      color: colors.secondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    ),
  );
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.textTheme,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colors;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            _IconBadge(icon: icon, colors: colors),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.textTheme,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colors;
  final TextTheme textTheme;
  final VoidCallback onTap;
  final bool destructive;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final foreground = destructive ? colors.error : colors.primary;
    return ListTile(
      onTap: onTap,
      minVerticalPadding: 14,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      leading: _IconBadge(icon: icon, colors: colors, destructive: destructive),
      title: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: destructive ? colors.error : colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: foreground),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.colors,
    this.destructive = false,
  });

  final IconData icon;
  final ColorScheme colors;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? colors.error : colors.primary;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 76, right: 18),
    child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppTheme.cardBorderDeep),
  );
}
