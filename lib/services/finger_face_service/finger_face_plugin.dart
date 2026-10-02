import 'dart:developer';

import 'package:canteen_pro/utils/permissions_handler.dart';
import 'package:newmidx_biometric/newmidx_biometric.dart';

/// App-wide singleton wrapper around [NewmidxBiometric].
///
/// Usage:
/// ```dart
/// await FingerFaceService.instance.init(); // inits fingerprint + face
/// final enrolled =
///     await FingerFaceService.instance.fingerprint.enroll(userId: 'user001');
/// ...
/// await FingerFaceService.instance.dispose(); // call when app/session ends
/// ```
class FingerFaceService {
  FingerFaceService._internal();

  static final FingerFaceService _instance = FingerFaceService._internal();

  /// The single shared instance.
  static FingerFaceService get instance => _instance;

  factory FingerFaceService() {
    return _instance;
  }

  final NewmidxBiometric _biometric = NewmidxBiometric();

  bool _fingerprintInitialized = false;
  bool _faceInitialized = false;
  bool _disposed = false;
  bool _busy = false;
  String _busyMessage = '';

  List<String> _faceGroups = [];
  List<String> get faceGroups => _faceGroups;

  /// Direct access to the underlying plugin instance, in case you need
  /// something the convenience getters below don't expose.
  NewmidxBiometric get biometric => _biometric;

  /// Shortcut for `biometric.fingerprint`.
  FingerprintApi get fingerprint => _biometric.fingerprint;

  /// Shortcut for `biometric.face`.
  FaceApi get face => _biometric.face;

  bool get isFingerprintInitialized => _fingerprintInitialized;
  bool get isFaceInitialized => _faceInitialized;
  bool get isDisposed => _disposed;

  /// Initializes whichever modalities you ask for. Safe to call more than
  /// once (and from multiple places) — already-initialized modalities are
  /// skipped, so app startup code can just call this unconditionally.
  Future<Map<String, bool>> init({
    bool fingerprint = true,
    bool face = true,
    String faceGroupName = FaceApi.defaultGroupName,
  }) async {
    _ensureNotDisposed();

    if (fingerprint && !_fingerprintInitialized) {
      final fingerRes = await _biometric.fingerprint.init();
      _fingerprintInitialized = fingerRes;
    }

    if (face && !_faceInitialized) {
      final faceRes = await _biometric.face.init();
      if (faceRes) {
        final groups = await _biometric.face.getGroups();
        _faceGroups = groups;
        if (!groups.contains(faceGroupName)) {
          await _biometric.face.createGroup(faceGroupName);
        }
      }
      _faceInitialized = faceRes;
    }

    if (face && fingerprint) {
      return { "All" : _fingerprintInitialized && _faceInitialized};
    } else if (face) {
      return { "Face" : _faceInitialized };
    } else if (fingerprint) {
      return { "Fingerprint" : _fingerprintInitialized };
    } else {
      return { "All Exception" : _fingerprintInitialized && _faceInitialized};
    }
  }

  Future<void> initFingerSDK() async {
    await _run(() async {
      _log('Initializing fingerprint SDK...');
      final ok = await _biometric.fingerprint.init();
      _fingerprintInitialized = ok;
      _log(ok ? 'SDK initialized' : 'SDK init returned false');
      if (ok) await _refreshUsers();
    });
  }

  // ---------------------------------------------------------------------
  // Fingerprint
  // ---------------------------------------------------------------------

  /// Enrolls a fingerprint for [userId]. Ensures fingerprint is initialized
  /// first. Returns `null` (via [guard]-style handling) if enrollment fails
  /// with a [BiometricException]; pass [onError] to inspect the failure.
  Future<FingerprintEnrollResult?> enrollFingerprint({
    required String userId,
    TemplateFormat templateFormat = TemplateFormat.ISO_19794_2_2011,
    void Function(BiometricException error)? onError,
  }) async {
    _ensureNotDisposed();
    if (!_fingerprintInitialized) {
      await _biometric.fingerprint.init();
      _fingerprintInitialized = true;
    }

    return guard(
          () => _biometric.fingerprint.enroll(
        userId: userId,
        templateFormat: templateFormat,
      ),
      onError: onError,
    );
  }

  /// Verifies a live fingerprint capture against the enrolled template for
  /// [userId]. Ensures fingerprint is initialized first.
  Future<FingerprintVerifyResult?> verifyFingerprint({
    required String userId,
    void Function(BiometricException error)? onError,
  }) async {
    _ensureNotDisposed();
    if (!_fingerprintInitialized) {
      await _biometric.fingerprint.init();
      _fingerprintInitialized = true;
    }

    return guard(
          () => _biometric.fingerprint.verify(userId: userId),
      onError: onError,
    );
  }

  Future<void> _refreshUsers() async {
    final users = await _biometric.fingerprint.getEnrolledUsers();
    log('Enrolled users: ${users.isEmpty ? "(none)" : users.join(", ")}');
  }

  Future<void> _deleteUser(String userId) async {
    if (userId.isEmpty) return;
    await guard(() async {
      final ok = await _biometric.fingerprint.deleteUser(userId);
      log('Delete $userId: ${ok ? "ok" : "failed"}');
      await _refreshUsers();
    });
  }

  Future<void> _clearAll() async {
    await guard(() async {
      final ok = await _biometric.fingerprint.clearAll();
      log('Clear all: ${ok ? "ok" : "failed"}');
      await _refreshUsers();
    });
  }

  /// Exports all [features] from the SDK's fingerprint database.
  Future<void> exportAll() async {
    await guard(() async {
      final all = await _biometric.fingerprint.exportAllTemplates();
      log('Exported ${all.length} template(s)');
      for (final item in all) {
        log(
          '${item.userId}: ${item.templateBytes.length} bytes, '
              'image ${item.imageBytes?.length ?? 0} bytes',
        );
      }
    });
  }

  // ---------------------------------------------------------------------
  // Face
  // ---------------------------------------------------------------------

  /// Enrolls a face for [userId] into [groupName]. Ensures face is
  /// initialized first (creating/using [FaceApi.defaultGroupName] if you
  /// haven't called [init] with a custom group yet).
  Future<FaceEnrollResult?> enrollFace({
    required String userId,
    String groupName = FaceApi.defaultGroupName,
    void Function(BiometricException error)? onError,
  }) async {
    _ensureNotDisposed();
    if (!_faceInitialized) {
      await _biometric.face.init();
      final groups = await _biometric.face.getGroups();
      _faceGroups = groups;
      if (!groups.contains(groupName)) {
        await _biometric.face.createGroup(groupName);
      }
      _faceInitialized = true;
    }

    return guard(
          () => _biometric.face.enroll(userId: userId, groupName: groupName),
      onError: onError,
    );
  }

  bool _liveRecognitionActive = false;

  /// Whether [startLiveRecognition] has been called without a matching
  /// [stopLiveRecognition] yet.
  bool get isLiveRecognitionActive => _liveRecognitionActive;

  /// Broadcasts match/stranger events while live recognition is running.
  /// Listen to this *before* or right after calling [startLiveRecognition].
  Stream<FaceLiveEvent> get onLiveRecognition =>
      _biometric.face.onLiveRecognition;

  /// Starts continuous face recognition against [groupName]. Ensures face
  /// is initialized first. Call [stopLiveRecognition] when you're done
  /// (e.g. leaving the screen) — it's also called automatically by
  /// [dispose].
  Future<void> startLiveRecognition({
    String groupName = FaceApi.defaultGroupName,
    void Function(BiometricException error)? onError,
  }) async {
    _ensureNotDisposed();
    if (!_faceInitialized) {
      await _biometric.face.init();
      _faceInitialized = true;
    }

    await guard(
          () => _biometric.face.startLiveRecognition(groupName: groupName),
      onError: onError,
    );
    _liveRecognitionActive = true;
  }

  /// Stops continuous face recognition started by [startLiveRecognition].
  /// Safe to call even if it isn't currently running.
  Future<void> stopLiveRecognition({
    void Function(BiometricException error)? onError,
  }) async {
    if (!_liveRecognitionActive) return;
    await guard(
          () => _biometric.face.stopLiveRecognition(),
      onError: onError,
    );
    _liveRecognitionActive = false;
  }

  /// Imports [features] into the SDK's face database.
  Future<String?> importFaceTemplates(List<FaceExportData> features) async {
    return await guard<String?>(() async {
      final res = await _biometric.face.importFeatures(features: features);
      if (res.allSucceeded) {
        log('Import all succeeded');
        return null;
      } else {
        log('Template import failed, failed: ${res.failed}');
        return 'Template import failed, failed: ${res.failed}';
      }
    });
  }

  /// Exports all [features] from the SDK's face database.
  Future<List<FaceExportData>?> exportFaceTemplates() async {
    return await guard<List<FaceExportData>?>(() async {
      final res = await _biometric.face.exportAllFeatures();
      if (res.isNotEmpty) {
        log('Export all succeeded');
        return res;
      } else {
        log('Template export failed, failed: ${res.length}');
        return null;
      }
    });
  }


  /// Runs [action] and converts a thrown [BiometricException] into a `null`
  /// result, invoking [onError] first if provided. Useful for call sites
  /// that just want a best-effort attempt without a try/catch block:
  ///
  /// ```dart
  /// final result = await BiometricManager.instance.guard(
  ///   () => BiometricManager.instance.face.enroll(userId: id),
  ///   onError: (e) => print('${e.code}: ${e.message}'),
  /// );
  /// ```
  Future<T?> guard<T>(
      Future<T> Function() action, {
        void Function(BiometricException error)? onError,
      }) async {
    try {
      return await action();
    } on BiometricException catch (e) {
      onError?.call(e);
      return null;
    }
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  final _logLines = <String>[];
  List<String> get logLines => _logLines;


  void _log(String message) {
      _logLines.insert(0, '${_timestamp()} $message');
      if (_logLines.length > 50) _logLines.removeLast();
  }

  Future<void> _run(
      Future<void> Function() action, {
        String busyMessage = 'Waiting for sensor...',
      }) async {
    if (_busy) return;
      _busy = true;
      _busyMessage = busyMessage;
    try {
      await action();
    } on BiometricException catch (e) {
      _log(_formatBiometricError(e));
    } catch (e) {
      _log('ERROR: $e');
    } finally {
       _busy = false;
    }
  }


  String _formatBiometricError(BiometricException e) {
    switch (e.code) {
      case BiometricErrorCode.permissionDenied:
        return 'ERROR: Permissions denied — ${e.message}';
      case BiometricErrorCode.manageStorageRequired:
        return 'ERROR: Grant "All files access" in settings, then tap Init again';
      case BiometricErrorCode.userNotFound:
        return 'User not found';
      default:
        return 'ERROR [${e.code.name}]: ${e.message}';
    }
  }

  /// Releases native resources (stopping any live face recognition first).
  /// After this the manager is considered disposed; call [init] again if
  /// you need biometrics for a new session.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    if (_liveRecognitionActive) {
      await stopLiveRecognition();
    }

    await _biometric.dispose();
    _fingerprintInitialized = false;
    _faceInitialized = false;
  }

  /// Allows a fresh session after [dispose] without restarting the app.
  void reset() {
    _disposed = false;
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError(
        'BiometricManager has already been disposed. '
            'Call reset() (or init() again after reset) before using it further.',
      );
    }
  }
}


// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:finger_face_bio_plugin/finger_face_bio_plugin.dart';
//
// /// Singleton service that wraps the `finger_face_bio_plugin` APIs
// /// (fingerprint + face recognition) behind a simpler, app-friendly
// /// interface with consistent error handling.
// ///
// /// Usage:
// /// ```dart
// /// final bio = FingerFaceBioService.instance;
// /// await bio.initialize();
// /// final token = await bio.enrollUserFace(groupName: 'staff');
// /// final matched = await bio.verifyUserFace(groupName: 'staff', faceToken: token!);
// /// ```
// class FingerFaceBioService {
//   FingerFaceBioService._internal();
//
//   static final FingerFaceBioService _instance = FingerFaceBioService._internal();
//
//   /// Global access point for the singleton.
//   static FingerFaceBioService get instance => _instance;
//
//   final FingerFaceBioPlugin _plugin = FingerFaceBioPlugin.instance;
//
//   bool _isInitialized = false;
//
//   /// Whether [initialize] has completed successfully.
//   bool get isInitialized => _isInitialized;
//
//   StreamSubscription<FaceRecognizeResult>? _continuousSub;
//
//   /// Whether continuous face recognition is currently running.
//   bool get isContinuousRecognitionActive => _continuousSub != null;
//
//   // ---------------------------------------------------------------------
//   // Initialization
//   // ---------------------------------------------------------------------
//
//   /// Initializes both the fingerprint and face SDKs and requests the
//   /// required device permissions. Safe to call multiple times; subsequent
//   /// calls are no-ops once initialization has succeeded.
//   Future<void> initialize() async {
//     if (_isInitialized) return;
//     try {
//       await _plugin.initialize();
//       _isInitialized = true;
//     } catch (e) {
//       _isInitialized = false;
//       throw BiometricServiceException('Initialization failed: $e');
//     }
//   }
//
//   void _ensureInitialized() {
//     if (!_isInitialized) {
//       throw BiometricServiceException(
//         'BiometricService has not been initialized. Call initialize() first.',
//       );
//     }
//   }
//
//   // ---------------------------------------------------------------------
//   // Fingerprint APIs
//   // ---------------------------------------------------------------------
//
//   /// Returns the list of fingerprint template types supported by the device.
//   Future<List<String>> getFingerprintTemplates() async {
//     _ensureInitialized();
//     try {
//       return await _plugin.getFingerprintTemplates();
//     } catch (e) {
//       throw BiometricServiceException('Error getting templates: $e');
//     }
//   }
//
//   /// Captures a fingerprint and returns the raw feature blob, or `null`
//   /// if capture failed. [templateName] is optional; the first available
//   /// template is used when omitted.
//   Future<Uint8List?> captureFingerprint({String? templateName}) async {
//     _ensureInitialized();
//     try {
//       final result = await _plugin.captureFingerprint(
//         templateName: templateName,
//       );
//       return result.feature;
//     } catch (e) {
//       throw BiometricServiceException('Fingerprint capture failed: $e');
//     }
//   }
//
//   /// Captures a fingerprint and returns the full [FingerprintCaptureResult]
//   /// (feature, template name, and optional image bytes).
//   Future<FingerprintCaptureResult> captureFingerprintFull({
//     String? templateName,
//   }) async {
//     _ensureInitialized();
//     try {
//       return await _plugin.captureFingerprint(templateName: templateName);
//     } catch (e) {
//       throw BiometricServiceException('Fingerprint capture failed: $e');
//     }
//   }
//
//   /// Compares two fingerprint feature blobs and returns the similarity
//   /// score (0-100), or `null` if the comparison failed.
//   Future<int?> compareFingerprints({
//     required Uint8List feature1,
//     required Uint8List feature2,
//     String? templateName,
//   }) async {
//     _ensureInitialized();
//     try {
//       final result = await _plugin.compareFingerprint(
//         feature1: feature1,
//         feature2: feature2,
//         templateName: templateName,
//       );
//       return result.isSuccess ? result.score : null;
//     } catch (e) {
//       throw BiometricServiceException('Fingerprint comparison failed: $e');
//     }
//   }
//
//   /// Compares two fingerprint feature blobs against a [threshold]
//   /// (default 70) and returns whether they are considered a match.
//   Future<bool> fingerprintsMatch({
//     required Uint8List feature1,
//     required Uint8List feature2,
//     int threshold = 70,
//     String? templateName,
//   }) async {
//     final score = await compareFingerprints(
//       feature1: feature1,
//       feature2: feature2,
//       templateName: templateName,
//     );
//     return score != null && score >= threshold;
//   }
//
//   // ---------------------------------------------------------------------
//   // Face APIs
//   // ---------------------------------------------------------------------
//
//   /// Validates a group name against the SDK's expected format
//   /// (letters, numbers, underscores; 16 characters or fewer).
//   void _validateGroupName(String groupName) {
//     final isValid = RegExp(r'^[A-Za-z0-9_]{1,16}$').hasMatch(groupName);
//     if (!isValid) {
//       throw BiometricServiceException(
//         'Invalid group name "$groupName": use ≤16 letters, numbers, or '
//             'underscores to avoid SDK "group name format invalid" errors.',
//       );
//     }
//   }
//
//   /// Opens the enrollment camera flow and enrolls a face into [groupName].
//   /// Returns the resulting face token, or `null` if enrollment failed.
//   Future<String?> enrollUserFace({required String groupName}) async {
//     _ensureInitialized();
//     _validateGroupName(groupName);
//     try {
//       final result = await _plugin.enrollFace(groupName: groupName);
//       if (result.isSuccess) return result.faceToken;
//       throw BiometricServiceException(
//         'Face enrollment failed: ${result.errorMessage}',
//       );
//     } catch (e) {
//       if (e is BiometricServiceException) rethrow;
//       throw BiometricServiceException('Error enrolling face: $e');
//     }
//   }
//
//   /// Verifies a live face capture against a previously saved [faceToken]
//   /// within [groupName]. Returns `true` if it's a match.
//   Future<bool> verifyUserFace({
//     required String groupName,
//     required String faceToken,
//   }) async {
//     _ensureInitialized();
//     _validateGroupName(groupName);
//     try {
//       final result = await _plugin.oneTimeVerify(
//         groupName: groupName,
//         faceToken: faceToken,
//       );
//       return result.isSuccess && result.isMatch;
//     } catch (e) {
//       throw BiometricServiceException('Error verifying face: $e');
//     }
//   }
//
//   /// Captures a live face and searches [groupName] for a matching token.
//   /// Returns the matched face token, or `null` if no match / cancelled.
//   Future<String?> recognizeUserFace({required String groupName}) async {
//     _ensureInitialized();
//     _validateGroupName(groupName);
//     try {
//       final result = await _plugin.oneTimeRecognize(groupName: groupName);
//       if (result.cancelled) return null;
//       if (result.isSuccess) return result.faceToken;
//       throw BiometricServiceException(
//         'Face recognition failed: ${result.errorMessage}',
//       );
//     } catch (e) {
//       if (e is BiometricServiceException) rethrow;
//       throw BiometricServiceException('Error recognizing face: $e');
//     }
//   }
//
//   /// Starts continuous face recognition against [groupName], invoking
//   /// [onRecognized] each time a face token is matched (throttled to a
//   /// 5-second interval by the SDK) and [onError] on stream errors.
//   /// Call [stopContinuousRecognition] to close the camera and cancel it.
//   void startContinuousRecognition({
//     required String groupName,
//     required void Function(String faceToken) onRecognized,
//     void Function(String message)? onError,
//     void Function()? onCancelled,
//   }) {
//     _ensureInitialized();
//     _validateGroupName(groupName);
//     stopContinuousRecognition();
//
//     _continuousSub = _plugin
//         .continuousFaceRecognition(groupName: groupName)
//         .listen(
//           (result) {
//         if (result.cancelled) {
//           onCancelled?.call();
//           stopContinuousRecognition();
//           return;
//         }
//         if (result.isSuccess && result.faceToken != null) {
//           onRecognized(result.faceToken!);
//         } else if (result.errorMessage != null) {
//           onError?.call(result.errorMessage!);
//         }
//       },
//       onError: (error) => onError?.call(error.toString()),
//     );
//   }
//
//   /// Stops continuous face recognition, if running, and closes the camera.
//   void stopContinuousRecognition() {
//     _continuousSub?.cancel();
//     _continuousSub = null;
//   }
//
//   // ---------------------------------------------------------------------
//   // Database management
//   // ---------------------------------------------------------------------
//
//   /// Returns the names of all existing face recognition groups.
//   Future<List<String>> getAllGroups() async {
//     _ensureInitialized();
//     try {
//       return await _plugin.getAllGroups();
//     } catch (e) {
//       throw BiometricServiceException('Error getting groups: $e');
//     }
//   }
//
//   /// Exports the SDK's entire face database as a JSON string.
//   Future<String> exportFaceDatabase() async {
//     _ensureInitialized();
//     try {
//       return await _plugin.exportFaceDatabase();
//     } catch (e) {
//       throw BiometricServiceException('Error exporting database: $e');
//     }
//   }
//
//   /// Exports the SDK's face database directly to [file].
//   Future<File> exportFaceDatabaseToFile(File file) async {
//     final jsonData = await exportFaceDatabase();
//     return file.writeAsString(jsonData);
//   }
//
//   /// Imports face database JSON (as previously produced by
//   /// [exportFaceDatabase]) into the SDK.
//   Future<void> importFaceDatabase(String jsonData) async {
//     _ensureInitialized();
//     try {
//       await _plugin.importFaceDatabase(jsonData: jsonData);
//     } catch (e) {
//       throw BiometricServiceException('Error importing database: $e');
//     }
//   }
//
//   /// Imports a face database JSON file (as previously produced by
//   /// [exportFaceDatabaseToFile]) into the SDK.
//   Future<void> importFaceDatabaseFromFile(File file) async {
//     final jsonData = await file.readAsString();
//     await importFaceDatabase(jsonData);
//   }
//
//   // ---------------------------------------------------------------------
//   // Cleanup
//   // ---------------------------------------------------------------------
//
//   /// Cancels any running continuous recognition stream. Call from your
//   /// top-level widget's `dispose()`.
//   void dispose() {
//     stopContinuousRecognition();
//   }
// }
//
// /// Exception type thrown by [FingerFaceBioService] so callers can catch
// /// biometric-specific failures distinctly from other errors.
// class BiometricServiceException implements Exception {
//   BiometricServiceException(this.message);
//
//   final String message;
//
//   @override
//   String toString() => 'BiometricServiceException: $message';
// }