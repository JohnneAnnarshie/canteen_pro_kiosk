import 'dart:developer';

import 'package:canteen_pro/models/member.dart';
import 'package:canteen_pro/repositories/repositories.dart';
import 'package:canteen_pro/services/encryption_helper.dart';
import 'package:canteen_pro/services/finger_face_service/finger_face_plugin.dart';
import 'package:canteen_pro/services/nfc_helper.dart';
import 'package:canteen_pro/services/palm_vein_plugin/palm_vein_service.dart';
import 'package:canteen_pro/shared/widgets/ui_utils.dart';
import 'package:canteen_pro/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/router/app_router.dart';
import '../../network/repos/network_config.dart';
import '../enrollment/user_provider.dart';
import '../landing/get_started_provider.dart';
import '../pre_order/order_provider.dart';

enum _IdentificationMethod { palm, face, nfc, qr }

final RouteObserver<ModalRoute<void>> routeObserver =
RouteObserver<ModalRoute<void>>();

class MemberAuthScreen extends ConsumerStatefulWidget {
  const MemberAuthScreen({super.key});

  @override
  ConsumerState<MemberAuthScreen> createState() => _MemberAuthScreenState();
}

class _MemberAuthScreenState extends ConsumerState<MemberAuthScreen> {
  final _staffIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _userRepository = UserRepository();
  final _palmService = PalmVeinService();
  final _faceService = FingerFaceService();

  _IdentificationMethod? _selectedMethod;
  Member? _member;
  bool _isLoading = false;
  String? _message;
  bool _isError = false;
  bool _isAdminMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetScreenState();
    });
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    super.dispose();
  }

  void _resetScreenState() {
    setState(() {
      _selectedMethod = null;
      _member = null;
      _message = null;
      _isError = false;
      _isLoading = false;
      _staffIdController.clear();
      _isAdminMode = false;
    });
  }

  void _selectMethod(_IdentificationMethod? method) {
    setState(() {
      if (method == _selectedMethod) {
        _selectedMethod = null;
      } else {
        _selectedMethod = method;
      }
      _member = null;
      _message = null;
      _isError = false;
      if (method != _IdentificationMethod.palm &&
          method != _IdentificationMethod.face) {
        _staffIdController.clear();
      }
    });
  }

  Future<void> _fetchMember() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _member = null;
      _message = null;
      _isError = false;
    });
    try {
      await _processRequest(_staffIdController.text.trim(), ignorePop: true, needsVerification: true);
    } on Exception {
      if (!mounted) return;
      setState(() {
        _message = 'We could not find that member. Check the ID and try again.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanBiometric() async {
    final member = _member;
    final method = _selectedMethod;
    if (_isLoading || member == null || method == null) return;

    setState(() {
      _isLoading = true;
      _message = method == _IdentificationMethod.palm
          ? 'Follow the scanner prompts to scan your palm.'
          : 'Position your face in front of the camera.';
      _isError = false;
    });

    try {
      String? errorMessage;
      if (method == _IdentificationMethod.palm) {
        await _palmService.initialize();
        errorMessage = await _palmService.authenticateUser(member.id);
      } else {
        final initialized = await _faceService.init(
          fingerprint: false,
          face: true,
        );
        if (initialized['Face'] != true) {
          throw StateError('Face scanner could not be initialized.');
        }
        final result = await _faceService.biometric.face.verify(
          userId: member.id,
        );
        if (!result.matched) {
          errorMessage = 'Face scan did not match this profile.';
        }
      }

      if (!mounted) return;
      setState(() {
        _message = errorMessage ?? 'Welcome, ${member.fullName}!';
        _isError = errorMessage != null;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _message = 'The scanner could not complete. Please try again.';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processRequest(String input, { bool ignorePop = false,
    bool needsVerification = false}) async {

    final response = await ref.read(orderState.notifier).fetchMemberByStaffId(input,
        onMemberFound: (member) async {
          if (!mounted) return;
          setState(() {
            _member = ref.read(orderState.notifier).currentMember;
            _message = 'Welcome, ${member.fullName}!';
          });
          if (!ignorePop) {
            Navigator.of(context).pop();
          }
          if (needsVerification) {
            return;
          } else {
            if (_isAdminMode && member.role == 1) {
              final res = await context.push(AppRoute.admin.path);
              if (res == true) {
                _resetScreenState();
                return;
              }
              return;
            }
            final orderRes = await context.push(AppRoute.preOrder.path);
            if (orderRes == true) {
              _resetScreenState();
            }
          }
          return;
        });
    if (response != null) {
      _setFailure(response);
      _processResult(response);
    }
  }

  Future<void> _scanNfc() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _message = 'Hold your NFC card near the reader.';
      _isError = false;
      _member = null;
    });
    try {
      showBioMetricDialog(context, onCancelled: () {
        NFCHelper().cancelScan();
      }, isNfc: true);

      final tagId = await NFCHelper().scanNFCTag();
      if (tagId == null || tagId.isEmpty) {
        if (!mounted) return;
        Navigator.of(context).pop();
        _setFailure('No NFC card was detected. Please try again.');
        _processResult('No NFC card was detected. Please try again.');
        return;
      }
      final encryptedTagId = CryptoHelper.encryptString(tagId);
      log('Encrypted tag ID: $encryptedTagId');
      await _processRequest(encryptedTagId);
    }
    // on Exception {
    //   _setFailure('Unable to read this NFC card. Please try again.');
    //   _processResult(Exception().toString());
    // }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _scanQr() async {
    if (_isLoading) return;
    final scannedValue = await showDialog<String>(
      context: context,
      builder: (context) => const _QrScannerDialog(),
    );
    if (!mounted || scannedValue == null || scannedValue.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _message = 'Looking up your profile...';
      _isError = false;
      _member = null;
    });
    try {
      final memberId = _memberIdFromQr(scannedValue);
      await _processRequest(memberId, ignorePop: true);
    }
    // on Exception {
    //   _setFailure('This QR code is not linked to a member profile.');
    // }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _memberIdFromQr(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasAuthority && uri.pathSegments.isNotEmpty) {
      return Uri.decodeComponent(uri.pathSegments.last);
    }
    final decrypted = CryptoHelper.decryptString(trimmed);
    return decrypted;
  }

  void _setFailure(String message) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isError = true;
    });
  }

  void _processResult(String? res, { Function()? onAlternateAction }) {
    if (res != null) {
      final isNotFound = res.contains("204");
      if (mounted) {
        showResultDialog(
          context,
          false,
          title: isNotFound ? 'Access Denied' : 'Error',
          message: isNotFound
              ? _selectedMethod == _IdentificationMethod.nfc ? "Invalid NFC card"
              : _selectedMethod == _IdentificationMethod.qr ? "Invalid QR data"
              : _selectedMethod == _IdentificationMethod.palm ? "Invalid palm data"
              :  "Invalid face data" : res,
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

  Future<void> _setAdminMode() async {
    setState(() {
      _isAdminMode = !_isAdminMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final colors = Theme.of(context).colorScheme;
    final columns = width >= 900 ? 4 : 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child:
            Image.asset(
              'assets/images/doodle_bg.png',
              fit: BoxFit.cover,
              color: Colors.black.withAlpha(86),
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
            ),
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _selectedMethod != null ? 500
                            : ResponsiveLayout.getScreenWidth(context)),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            width >= 700 ? 48 : 20,
                            34,
                            width >= 700 ? 48 : 20,
                            28,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                appIconDarkPath,
                                color: colors.primary,
                                width: 74,
                                height: 74,
                              ),
                              const SizedBox(height: 13),
                              Text(
                                'Canteen Pro',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: const Color(0xFF151D45),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isAdminMode ? 'Admin mode' : 'Welcome',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(color: colors.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select authentication method',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: colors.onSurface),
                              ),
                              const SizedBox(height: 30),
                              _selectedMethod != null ?
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(onPressed: () {
                                      _selectMethod(null);
                                    },
                                        icon: Icon(
                                          Icons.close,
                                          color: colors.primary,
                                        ),
                                        iconSize: 34,
                                      style: IconButton.styleFrom(
                                        backgroundColor: colors.primary.withAlpha(30),
                                        foregroundColor: colors.onPrimary,
                                      )
                                    ),
                                  ) :
                              GridView.count(
                                crossAxisCount: columns,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: width >= 900 ? 1.2 : 1.18,
                                children: [
                                  _MethodCard(
                                    title: 'Palm vein',
                                    subtitle: 'Scan your palm',
                                    icon: LucideIcons.hand,
                                    selected:
                                        _selectedMethod == _IdentificationMethod.palm,
                                    onTap: () =>
                                        _selectMethod(_IdentificationMethod.palm),
                                  ),
                                  _MethodCard(
                                    title: 'Face scan',
                                    subtitle: 'Look at the camera',
                                    icon: LucideIcons.scanFace,
                                    selected:
                                        _selectedMethod == _IdentificationMethod.face,
                                    onTap: () =>
                                        _selectMethod(_IdentificationMethod.face),
                                  ),
                                  _MethodCard(
                                    title: 'NFC card',
                                    subtitle: 'Tap your staff card',
                                    icon: LucideIcons.idCardLanyard,
                                    selected:
                                        _selectedMethod == _IdentificationMethod.nfc,
                                    onTap: () =>
                                        _selectMethod(_IdentificationMethod.nfc),
                                  ),
                                  _MethodCard(
                                    title: 'QR code',
                                    subtitle: 'Scan your member code',
                                    icon: Icons.qr_code_scanner_rounded,
                                    selected:
                                        _selectedMethod == _IdentificationMethod.qr,
                                    onTap: () =>
                                        _selectMethod(_IdentificationMethod.qr),
                                  ),
                                ],
                              ),
                              if (_selectedMethod != null) ...[
                                const SizedBox(height: 20),
                                _buildActionPanel(colors),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE8EAF1))),
                    ),
                    child: Row(
                      children: [
                        TextButton.icon(
                          onPressed: _setAdminMode,
                          icon: Icon(_isAdminMode ?  Icons.close
                              : Icons.admin_panel_settings_outlined),
                          label: Text(_isAdminMode ? 'Exit admin mode' : 'Admin mode'),
                          style: TextButton.styleFrom(
                            foregroundColor: _isAdminMode ? colors.error : const Color(0xFF555E78),
                            backgroundColor: _isAdminMode ? colors.error.withAlpha(30)
                                : colors.primary.withAlpha(30),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Secure member identification',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel(ColorScheme colors) {
    final method = _selectedMethod!;
    final needsStaffId =
        method == _IdentificationMethod.palm ||
        method == _IdentificationMethod.face;

    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      width: 500,
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            needsStaffId
                ? 'Enter staff ID'
                : method == _IdentificationMethod.nfc
                ? 'Ready to scan your NFC card?'
                : 'Ready to scan your QR code?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF202848),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (needsStaffId) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 500,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _staffIdController,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _fetchMember(),
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    hintText: 'Enter the member’s staff ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Please enter a staff ID'
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 500,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _fetchMember,
                child: _isLoading
                    ? _progressIndicator()
                    : Text('Find profile', style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
              ),
            ),
            if (_member != null) ...[
              const SizedBox(height: 14),
              _MemberProfileCard(member: _member!),
              const SizedBox(height: 12),
              SizedBox(
                width: 500,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _scanBiometric,
                  icon: Icon(
                    method == _IdentificationMethod.palm
                        ? Icons.pan_tool_alt_rounded
                        : Icons.face_retouching_natural_rounded,
                  ),
                  label: Text(
                    method == _IdentificationMethod.palm
                        ? 'Continue to palm scan'
                        : 'Continue to face scan',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )
                ),
              ),
              )
            ],
          ] else ...[
            const SizedBox(height: 8),
            Text(
              method == _IdentificationMethod.nfc
                  ? 'Keep your card close to the reader until it is detected.'
                  : 'Hold your member QR code in front of the camera.',
              style: const TextStyle(color: Color(0xFF69718B)),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 500,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : method == _IdentificationMethod.nfc
                    ? _scanNfc
                    : _scanQr,
                icon: Icon(
                  method == _IdentificationMethod.nfc
                      ? Icons.contactless_rounded
                      : Icons.qr_code_scanner_rounded,
                ),
                label: _isLoading
                    ? _progressIndicator()
                    : Text(
                        method == _IdentificationMethod.nfc
                            ? 'Start NFC scan'
                            : 'Open QR scanner',
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )
                      ),
              ),
            ),
          ],
          if (_message != null) ...[
            const SizedBox(height: 14),
            Text(
              _message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: textTheme.titleMedium?.fontFamily,
                color: _isError ? colors.error : colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _progressIndicator() => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? const Color(0xFFEEF1FF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? primary : colors.primary.withAlpha(60),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: selected ? primary : const Color(0xFFF1F3F8),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : colors.primary,
                  size: 35,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberProfileCard extends StatelessWidget {
  const _MemberProfileCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final initials = member.fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1C2864),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  member.staffId,
                  style: const TextStyle(color: Color(0xFF737B92)),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF18864B)),
        ],
      ),
    );
  }
}


class _QrScannerDialog extends StatefulWidget {
  const _QrScannerDialog();

  @override
  State<_QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<_QrScannerDialog>
    with SingleTickerProviderStateMixin {
  static const double _cutoutSize = 260;

  bool _didDetect = false;

  final MobileScannerController _cameraController = MobileScannerController(
    facing: CameraFacing.front,
    formats: [BarcodeFormat.qrCode],
  );

  late final AnimationController _lineController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  Rect _cutoutRect(Size size) => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: _cutoutSize,
    height: _cutoutSize,
  );

  @override
  void dispose() {
    _lineController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.onPrimary;
    final topInset = MediaQuery.paddingOf(context).top;

    return Dialog.fullscreen(
      child: LayoutBuilder(
        builder: (context, dialogConstraints) {
          // Same rect for the detection area and the visual cutout.
          final scanWindow = _cutoutRect(dialogConstraints.biggest);

          return Stack(
            children: [
              MobileScanner(
                controller: _cameraController,
                scanWindow: scanWindow,
                onDetect: (capture) {
                  if (_didDetect) return;
                  final values = capture.barcodes
                      .map((barcode) => barcode.rawValue)
                      .whereType<String>()
                      .toList();
                  if (values.isEmpty || values.first.isEmpty) return;
                  _didDetect = true;
                  Navigator.of(context).pop(values.first);
                },
                overlayBuilder: (context, constraints) {
                  final rect = _cutoutRect(constraints.biggest);
                  return IgnorePointer(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _ScannerOverlayPainter(
                            cutout: rect,
                            cornerColor: accent,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _lineController,
                          builder: (context, _) {
                            final top = rect.top +
                                12 +
                                (rect.height - 24) * _lineController.value;
                            return Positioned(
                              left: rect.left + 16,
                              width: rect.width - 32,
                              top: top,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: accent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withAlpha(160),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              Positioned(
                top: topInset + 16,
                left: 16,
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 34),
                  tooltip: 'Close scanner',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(30),
                  ),
                ),
              ),
              Positioned(
                top: topInset + 16,
                right: 16,
                child: IconButton.filledTonal(
                  onPressed: () => _cameraController.switchCamera(),
                  icon: const Icon(Icons.cameraswitch_outlined, size: 34),
                  tooltip: 'Switch camera',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(30),
                  ),
                ),
              ),
              const Positioned(
                left: 24,
                right: 24,
                bottom: 36,
                child: Text(
                  'Place the member QR code inside the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  _ScannerOverlayPainter({required this.cutout, required this.cornerColor});

  final Rect cutout;
  final Color cornerColor;

  static const double _radius = 16;
  static const double _cornerLength = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect =
    RRect.fromRectAndRadius(cutout, const Radius.circular(_radius));

    // Dimmed background with a transparent hole.
    final background = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rrect),
    );
    canvas.drawPath(background, Paint()..color = Colors.black.withAlpha(150));

    // Corner brackets.
    final paint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final l = cutout.left, t = cutout.top, r = cutout.right, b = cutout.bottom;
    const c = _cornerLength;
    const rad = _radius;

    final path = Path()
      ..moveTo(l, t + c)
      ..lineTo(l, t + rad)
      ..arcToPoint(Offset(l + rad, t), radius: const Radius.circular(rad))
      ..lineTo(l + c, t)
      ..moveTo(r - c, t)
      ..lineTo(r - rad, t)
      ..arcToPoint(Offset(r, t + rad), radius: const Radius.circular(rad))
      ..lineTo(r, t + c)
      ..moveTo(r, b - c)
      ..lineTo(r, b - rad)
      ..arcToPoint(Offset(r - rad, b), radius: const Radius.circular(rad))
      ..lineTo(r - c, b)
      ..moveTo(l + c, b)
      ..lineTo(l + rad, b)
      ..arcToPoint(Offset(l, b - rad), radius: const Radius.circular(rad))
      ..lineTo(l, b - c);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter old) =>
      old.cutout != cutout || old.cornerColor != cornerColor;
}
