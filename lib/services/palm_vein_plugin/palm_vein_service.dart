import 'dart:async';
import 'dart:developer';

import 'package:newmidx_biometric/newmidx_biometric.dart';






/// Singleton service wrapping the [PalmVein] plugin.
///
/// Use [PalmVeinService.instance] to access the shared instance.
/// Call [initialize] once (e.g. at app startup or before first use),
/// and [dispose] when the app/screen is fully done with the plugin.
class PalmVeinService {

  PalmVeinService._internal();

  static final PalmVeinService instance = PalmVeinService._internal();

  final PalmVp530Api _palm = NewmidxBiometric().palm;

  factory PalmVeinService () => instance;

  bool _initialized = false;
  bool _deviceOpen = false;

  /// Expose the underlying streams so listeners can subscribe
  /// through the singleton without reaching into the plugin directly.;
  Stream<dynamic> get onHint => _palm.onHint;
  Stream<dynamic> get onCaptureProgress => _palm.onCaptureProgress;
  Stream<dynamic> get onVerifyResult => _palm.onVerifyResult;

  bool get isInitialized => _initialized;
  bool get isDeviceOpen => _deviceOpen;

  /// Initializes the plugin. Safe to call multiple times;
  /// subsequent calls are no-ops once initialized.
  Future<void> initialize() async {
    if (_initialized) return;
    await _palm.initialize();
    _initialized = true;
    log(name: 'PALM-VEIN SERVICE','Initialized');
  }

  /// Opens the device. Returns device info from the plugin.
  Future<dynamic> openDevice() async {
    if (!_initialized) {
      throw StateError('PalmVeinService not initialized. Call initialize() first.');
    }
    if (_deviceOpen) return null;
    final info = await _palm.openDevice();
    _deviceOpen = true;
    return info;
  }

  Future<Map<bool, dynamic>> enroll(
      String userId,
      {
        required Set<PalmHand> hands,
        bool isUpdate = false,
        String? palmFeature,
        bool rejectDuplicates = true
      }) async {
    try {
      await openDevice();
      _ensureDeviceOpen();
      if (isUpdate) {
        final PalmUser ures = await _palm.enroll(userId: userId);

        final res = await _palm.capturePalms(
            hands: hands,
        );

        await closeDevice();
        return { true: getNonEmptyFeature(res, true)};
      } else {
        final result = await _palm.capturePalms(hands: hands);
        await closeDevice();
        return { true: getNonEmptyFeature(result, false)};
      }
    } on Exception catch (e) {
      await closeDevice();
      return { false: setErrorMessage(e.toString()) };
    }
  }


  Future<String?> authenticateUser(String userId) async {
    try {
      await openDevice();
      _ensureDeviceOpen();
      final auth = await _palm.verify(userId: userId);
      await closeDevice();
      if (auth.matched) {
        log(name: 'PALM-VEIN SERVICE','Authenticated ${auth.userId}');
        return null;
      } else {
        return 'Access denied, invalid palm data';
      }
    } on Exception catch (e) {
      await closeDevice();
      return setErrorMessage(e.toString());
    }
  }

  Future<void> closeDevice() async {
    if (!_deviceOpen) return;
    await _palm.closeDevice();
    _deviceOpen = false;
  }

  /// Fully tears down the plugin. After calling this, [initialize]
  /// must be called again before further use.
  Future<void> dispose() async {
    if (_deviceOpen) {
      await closeDevice();
    }
    if (_initialized) {
      await _palm.dispose();
      _initialized = false;
    }
  }

  void _ensureDeviceOpen() {
    if (!_deviceOpen) {
      throw StateError('Device is not open. Call openDevice() first.');
    }
  }


  Future<String?> exportTemplates() async {
    // try {
    //   final res = await _palm.exportTemplates();
    //   if (res.users.isEmpty) {
    //     return 'No templates exported';
    //   }
    //   return null;
    // } on Exception catch (e) {
    //   log(name: 'PALM-VEIN SERVICE','Error exporting templates: $e');
    //   rethrow;
    // }
    return null;
  }

  Future<String?> importTemplates(List<PalmTemplate> export) async {
    // try {
    //   final res = await _palm.importTemplates(export);
    //   if (res.succeeded == 0) {
    //     return 'No templates imported';
    //   }
    //   return null;
    // } on Exception catch (e) {
    //   log(name: 'PALM-VEIN SERVICE','Error importing templates: $e');
    //   rethrow;
    // }
    return null;
  }

  Future<int?> clearAllData() async {
    log(name: 'PALM-VEIN SERVICE','Clearing all data');
    return await _palm.clearAll();
  }


  String setErrorMessage (String errorMessage) {
    if (errorMessage.contains('Palm already enrolled for another user')) {
      return 'Palm already enrolled for another user';
    }
    if (errorMessage.contains('User already enrolled')) {
      return 'User already enrolled';
    }
    if (errorMessage.contains('not enrolled')) {
      return 'Employee has not been enrolled';
    }
    if (errorMessage.toLowerCase().contains('has no palm templates')) {
      return 'Employee has not been enrolled';
    }
    if (errorMessage.toLowerCase().contains('Device not ready')) {
      return 'Device not ready\nPlease try again';
    }
    if (errorMessage.toLowerCase().contains('device not open')) {
      return 'Device not open';
    }
    return errorMessage;
  }

  List<LabeledPalmTemplate>? getNonEmptyFeature(PalmCaptureResult result, bool isUpdate) {
    if (isUpdate) {
      if (result.leftFeature != null) {
        return [LabeledPalmTemplate(
          palmFeature: result.leftFeature!,
          palmType: 'LEFT',
        )
        ];
      }
      if (result.rightFeature != null) {
        return [LabeledPalmTemplate(
          palmFeature: result.rightFeature!,
          palmType: 'RIGHT',
        )
        ];
      }
    } else {
      if (result.leftFeature != null && result.rightFeature != null) {
        return [
          LabeledPalmTemplate(
            palmFeature: result.leftFeature!,
            palmType: 'LEFT',
          ),
          LabeledPalmTemplate(
            palmFeature: result.rightFeature!,
            palmType: 'RIGHT',
          )
        ];
      }
    }
    return null;
  }

}

class LabeledPalmTemplate {
  final String palmFeature;
  final String palmType;

  const LabeledPalmTemplate({
    required this.palmFeature,
    required this.palmType,
  });
}