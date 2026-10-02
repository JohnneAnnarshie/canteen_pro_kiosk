import 'package:canteen_pro/utils/responsive_layout.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../models/device_set_up.dart';
import '../../network/repos/network_config.dart';
import '../../services/device_info_service.dart';
import '../../shared/widgets/ui_utils.dart';
import '../landing/get_started_provider.dart';
import 'device_provider.dart';

class DeviceSetupScreen extends ConsumerStatefulWidget {
  const DeviceSetupScreen({super.key});

  @override
  ConsumerState<DeviceSetupScreen> createState() => _DeviceSetupScreenState();
}

class _DeviceSetupScreenState extends ConsumerState<DeviceSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _serialController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  bool _codeSubmitted = false;
  bool _isLoading = false;
  bool _isSavingDevice = false;
  bool _showInstructions = false;
  NetworkPhysicalDevice? _networkPhysicalDevice;
  NetworkDeviceSetUp? _networkDeviceSetUp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDeviceInformation();
      _checkForAvailableDevice();
    });
  }

  @override
  void dispose() {
    for (final controller in [
      _codeController,
      _nameController,
      _typeController,
      _serialController,
      _brandController,
      _modelController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void getDeviceInformation() async {
    AndroidDeviceInfo deviceInfo = await _deviceInfoPlugin.androidInfo;
    final serial = await DeviceInfoService().getDeviceSerialNumber();
    setState(() {
      _serialController.text = serial;
      _brandController.text = deviceInfo.brand;
      _modelController.text = deviceInfo.model;
    });
  }

  void _checkForAvailableDevice() async {
    final serial = await DeviceInfoService().getDeviceSerialNumber();
    final res = await ref.watch(deviceSetUpProvider.notifier).getPhysicalDeviceBySerialNumber(serial,
      (device) {
      if (device != null) {
        setState(() => _networkPhysicalDevice = device);
        _showDeviceFoundDialog(device);
      }
    });
    _processResult(res);
  }

  void _processResult(String? res, { Function()? onAlternateAction}) {
    if (res != null) {
      if (mounted) {
        showResultDialog(
          context,
          false,
          title: 'Error',
          message: res.contains("204")
              ? 'Device not found. Please check the code and try again.' : res,
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

  void _submitCode() async {
    setState(() => _isLoading = true);

    if (_codeController.text.trim().isEmpty) {
      setState(() => _codeSubmitted = false);
      _formKey.currentState?.validate();
      return;
    }
    final res = await ref.read(deviceSetUpProvider.notifier).getDeviceByCode(_codeController.text.trim(),
    (device) {
      if (device != null) {
        setState(() {
          _nameController.text = device.name;
          _typeController.text = device.deviceType;
          _networkDeviceSetUp = device;
        });
      }
    });
    setState(() => _isLoading = false);

    _processResult(res, onAlternateAction: () {
      setState(() => _codeSubmitted = true);
    });
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    if (_networkDeviceSetUp == null) {
      showResultDialog(
        context,
        false,
        title: 'Error',
        message: 'Invalid Device id, please try again.',
      );
      return;
    }

    setState(() => _isSavingDevice = true);
    final res = await ref
        .read(deviceSetUpProvider.notifier)
        .submitDeviceSetup(
          DeviceSetUp(
            deviceSetupId: _networkDeviceSetUp?.id ?? "",
            deviceName: _nameController.text.trim(),
            serialNumber: _serialController.text.trim(),
            code: _codeController.text.trim(),
            brand: _brandController.text.trim(),
            model: _modelController.text.trim(),
            deviceType: _typeController.text.trim(),
            status: _networkDeviceSetUp?.status ?? false,
          ),
        );
    setState(() => _isSavingDevice = false);
    if (!mounted) return;
    _processResult(res);
  }

  Future<void> _saveExistingPhysicalDevice(NetworkPhysicalDevice physicalDevice, StateSetter putState) async {
    putState(() => _isLoading = true);

    if (physicalDevice.code == null) {
      return;
    }

    final res = await ref.read(deviceSetUpProvider.notifier).getDeviceByCode(physicalDevice.code ?? "",
            (device) async {
          if (device != null) {
            if (mounted) Navigator.pop(context);
            await ref.read(deviceSetUpProvider.notifier).saveDeviceSetup(
              DeviceSetUp(
                deviceSetupId: device.id,
                deviceName: device.name,
                serialNumber: physicalDevice.serialNumber,
                code: device.code,
                brand: physicalDevice.brand,
                model: physicalDevice.model,
                deviceType: device.deviceType,
                status: physicalDevice.status == 1,
              )
            );
          }
        });
    putState(() => _isLoading = false);
    _processResult(res);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isExpanded = ResponsiveLayout.getScreenWidth(context) > 900;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary,
        toolbarHeight: kToolbarHeight + 10,
        elevation: 0,
        leading: Icon(
          isExpanded ? Icons.tablet : Icons.phone_android,
          color: colorScheme.onPrimary,
          size: 30,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Setup', style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary
            )),
            Text(
              'Set up device for canteen',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
        actions:  [
          if (_networkPhysicalDevice != null) ...[
          TextButton.icon(
              onPressed: () => _showDeviceFoundDialog(_networkPhysicalDevice),
              style: TextButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainer,
                side: BorderSide(
                    color: AppTheme.surfaceVariantLight
                ),
              ),
              icon: Icon(isExpanded ? Icons.phone_android : Icons.tablet, color: colorScheme.onSurface),
              label: Text('Get Existing Device')
          )],
          if (!isExpanded)...[
            const SizedBox(width: 10),
            IconButton(
              onPressed: () {
                setState(() {
                  _showInstructions = true;
                });
              },
              icon: const Icon(Icons.help_outline, color: Colors.white,),
            ),
          ]

        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 900;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 20 : 22,
                isCompact ? 18 : 34,
                isCompact ? 20 : 22,
                20,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                constraints: const BoxConstraints(maxWidth: 1280),
                child:
                    isCompact
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AnimatedSwitcher(
                                duration: Duration(milliseconds: 600),
                                reverseDuration: Duration(milliseconds: 600),
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: _showInstructions ? _buildInstructions(isCompact: true, onClosed: () {
                                  setState(() {
                                    _showInstructions = false;
                                  });
                                }) : SizedBox.shrink()
                            ),
                            _showInstructions ? const SizedBox(height: 28) : SizedBox.shrink(),
                            _buildForm(),
                          ],
                        )
                        : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: _buildForm()),
                            const SizedBox(width: 22),
                            Expanded(flex: 5, child: _buildInstructions()),
                          ],
                        ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _field(
                  controller: _codeController,
                  hint: 'Device code',
                  icon: Icons.vpn_key_rounded,
                  isReadOnly: !_isSavingDevice && !_isLoading,
                  onValueChanged: (e) {
                    setState(() {
                      _nameController.clear();
                      _typeController.clear();
                    });
                  },
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Required'
                              : null,
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading || _isSavingDevice ? () {} : _submitCode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(140, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _isLoading ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ) : Text('Get Device', style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _field(
            controller: _nameController,
            hint: 'Device name',
            icon: Icons.info,
            validator: _required,
          ),
          const SizedBox(height: 18),
          _field(
            controller: _typeController,
            hint: 'Device Type',
            icon: Icons.devices,
            validator: _required,
          ),
          const SizedBox(height: 18),

          _field(
            controller: _serialController,
            label: 'Serial number',
            hint: 'Serial number',
            icon: Icons.password,
            validator: _required,
            isReadOnly: false,
          ),

          const SizedBox(height: 18),
          _field(
            controller: _brandController,
            label: 'Brand',
            hint: 'Brand',
            icon: Icons.devices,
            validator: _required,
          ),
          const SizedBox(height: 18),
          _field(
            controller: _modelController,
            label: 'Model',
            hint: 'Model',
            icon: Icons.tablet_android,
            validator: _required,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton(
              onPressed: _isLoading || _isSavingDevice ? () {} : _saveDevice,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSavingDevice ? colorScheme.tertiary : AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: _isSavingDevice ?
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
                      Text('Saving device...', style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold))
                    ]
                  ): Text('Save device', style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? label,
    String? Function(String?)? validator,
    Function(String)? onValueChanged,
    bool isReadOnly = true
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onValueChanged,
      style: TextStyle(fontSize: textTheme.titleMedium?.fontSize, color: Color(0xFF42414B)),
      readOnly: isReadOnly,
      onTapOutside: (e) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: TextStyle(fontSize: textTheme.titleMedium?.fontSize, color: Color(0xFF42414B)),
        prefixIcon: Icon(icon, size: 22, color: const Color(0xFF4B4A55)),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF8E8C91), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF8E8C91), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Widget _buildInstructions({ bool isCompact = false, VoidCallback? onClosed }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 30),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EEF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          if (!isCompact) ...[
          SizedBox(
            height: 320,
            child: Image.asset(
              'assets/images/device_config.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
            Text(
              'Instructions',
              style: TextStyle(fontSize:
              textTheme.titleMedium?.fontSize, fontWeight: FontWeight.w700),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Instructions',
                  style: TextStyle(fontSize:
                  textTheme.titleMedium?.fontSize, fontWeight: FontWeight.w700),
                ),
                IconButton(onPressed: onClosed,
                    icon: const Icon(Icons.close)),
              ],
            )
          ],
          SizedBox(height: isCompact ? 12 : 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF9FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                _InstructionRow(
                  Icons.vpn_key_rounded,
                  'Enter and submit the device code provided by your admin.',
                ),
                SizedBox(height: 12),
                _InstructionRow(
                  Icons.info,
                  'Ensure the provided device data are correct.',
                ),
                SizedBox(height: 12),
                _InstructionRow(
                  Icons.sync,
                  'If serial number retrieval fails, enter it manually.',
                ),
                SizedBox(height: 12),
                _InstructionRow(
                  Icons.send,
                  "Click on 'Submit' to complete the setup process.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

   void _showDeviceFoundDialog(NetworkPhysicalDevice? device) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isCompact = ResponsiveLayout.getScreenWidth(context) < 900;

    if (device == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, putState) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: isCompact ? 30 : 40,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Device Found',
                              style: textTheme.displayMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompact ? Icons.phone_android : Icons.tablet,
                            color: colorScheme.primary,
                            size: isCompact ? 40 : 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Code: ${device.code ?? "N/A"},  Brand: ${device.brand},  Model: ${device.model}',
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
                            onPressed: _isLoading ? () {} : () => _saveExistingPhysicalDevice(device, putState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
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
                                  Text('Saving device...', style: textTheme.titleMedium?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold))
                                ]
                            ): Text(
                                'Save and continue', style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold
                            )),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: ResponsiveLayout.getCardWidth(context),
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary.withAlpha(40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: Text(
                                'Set up new device', style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold
                            )),
                          ),
                        ),
                      ]
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primary, size: 19),
        const SizedBox(width: 13),
        Expanded(
          child: Text(text, style:
          TextStyle(fontSize: textTheme.bodyMedium?.fontSize, height: 1.35)),
        ),
      ],
    );
  }
}
