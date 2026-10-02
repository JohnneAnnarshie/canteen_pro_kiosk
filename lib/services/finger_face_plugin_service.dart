import 'package:newmidx_biometric/newmidx_biometric.dart';

/// App-wide singleton wrapper around [NewmidxBiometric].
///
/// Usage:
/// ```dart
/// await BiometricManager.instance.init(); // inits fingerprint + face
/// final enrolled =
///     await BiometricManager.instaimport 'package:newmidx_biometric/newmidx_biometric.dart';
/// ...
/// await BiometricManager.instance.dispose(); // call when app/session ends
/// ```
class BiometricManager {
  BiometricManager._internal();

  static final BiometricManager _instance = BiometricManager._internal();

  /// The single shared instance.
  static BiometricManager get instance => _instance;

  final NewmidxBiometric _biometric = NewmidxBiometric();

  bool _fingerprintInitialized = false;
  bool _faceInitialized = false;
  bool _disposed = false;

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
  Future<void> init({
    bool fingerprint = true,
    bool face = true,
    String faceGroupName = FaceApi.defaultGroupName,
  }) async {
    _ensureNotDisposed();

    if (fingerprint && !_fingerprintInitialized) {
      await _biometric.fingerprint.init();
      _fingerprintInitialized = true;
    }

    if (face && !_faceInitialized) {
      await _biometric.face.init();
      final groups = await _biometric.face.getGroups();
      _faceGroups = groups;
      if (!groups.contains(faceGroupName)) {
        await _biometric.face.createGroup(faceGroupName);
      }
      _faceInitialized = true;
    }
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


// import 'package:newmidx_biometric/newmidx_biometric.dart';
//
// /// App-wide singleton wrapper around [NewmidxBiometric].
// ///
// /// Usage:
// /// ```dart
// /// await BiometricManager.instance.init(); // inits fingerprint + face
// /// final enrolled =
// ///     await BiometricManager.instance.fingerprint.enroll(userId: 'user001');
// /// ...
// /// await BiometricManager.instance.dispose(); // call when app/session ends
// /// ```
// class BiometricManager {
//   BiometricManager._internal();
//
//   static final BiometricManager _instance = BiometricManager._internal();
//
//   /// The single shared instance.
//   static BiometricManager get instance => _instance;
//
//   final NewmidxBiometric _biometric = NewmidxBiometric();
//
//   bool _fingerprintInitialized = false;
//   bool _faceInitialized = false;
//   bool _disposed = false;
//
//   List<String> _faceGroups = [];
//   List<String> get faceGroups => _faceGroups;
//
//   /// Direct access to the underlying plugin instance, in case you need
//   /// something the convenience getters below don't expose.
//   NewmidxBiometric get biometric => _biometric;
//
//   /// Shortcut for `biometric.fingerprint`.
//   FingerprintApi get fingerprint => _biometric.fingerprint;
//
//   /// Shortcut for `biometric.face`.
//   FaceApi get face => _biometric.face;
//
//   bool get isFingerprintInitialized => _fingerprintInitialized;
//   bool get isFaceInitialized => _faceInitialized;
//   bool get isDisposed => _disposed;
//
//   /// Initializes whichever modalities you ask for. Safe to call more than
//   /// once (and from multiple places) — already-initialized modalities are
//   /// skipped, so app startup code can just call this unconditionally.
//   Future<void> init({
//     bool fingerprint = true,
//     bool face = true,
//     String faceGroupName = FaceApi.defaultGroupName,
//   }) async {
//     _ensureNotDisposed();
//
//     if (fingerprint && !_fingerprintInitialized) {
//       await _biometric.fingerprint.init();
//       _fingerprintInitialized = true;
//     }
//
//     if (face && !_faceInitialized) {
//       await _biometric.face.init();
//       final groups = await _biometric.face.getGroups();
//
//       _faceGroups = groups;
//       if (!groups.contains(faceGroupName)) {
//         await _biometric.face.createGroup(faceGroupName);
//       }
//
//       //await _biometric.face.createGroup(faceGroupName);
//       //await _biometric.face.deleteGroup('old_gallery');
//       _faceInitialized = true;
//     }
//   }
//
//   /// Runs [action] and converts a thrown [BiometricException] into a `null`
//   /// result, invoking [onError] first if provided. Useful for call sites
//   /// that just want a best-effort attempt without a try/catch block:
//   ///
//   /// ```dart
//   /// final result = await BiometricManager.instance.guard(
//   ///   () => BiometricManager.instance.face.enroll(userId: id),
//   ///   onError: (e) => print('${e.code}: ${e.message}'),
//   /// );
//   /// ```
//   Future<T?> guard<T>(
//       Future<T> Function() action, {
//         void Function(BiometricException error)? onError,
//       }) async {
//     try {
//       return await action();
//     } on BiometricException catch (e) {
//       onError?.call(e);
//       return null;
//     }
//   }
//
//   /// Releases native resources (stopping any live face recognition first).
//   /// After this the manager is considered disposed; call [init] again if
//   /// you need biometrics for a new session.
//   Future<void> dispose() async {
//     if (_disposed) return;
//     _disposed = true;
//
//     if (_faceInitialized) {
//       try {
//         await _biometric.face.stopLiveRecognition();
//       } catch (_) {
//         // Ignore — live recognition may not have been running.
//       }
//     }
//
//     await _biometric.dispose();
//     _fingerprintInitialized = false;
//     _faceInitialized = false;
//   }
//
//   /// Allows a fresh session after [dispose] without restarting the app.
//   void reset() {
//     _disposed = false;
//   }
//
//   void _ensureNotDisposed() {
//     if (_disposed) {
//       throw StateError(
//         'BiometricManager has already been disposed. '
//             'Call reset() (or init() again after reset) before using it further.',
//       );
//     }
//   }
// }