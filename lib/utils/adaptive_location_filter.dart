import 'dart:math';
import 'package:geolocator/geolocator.dart';

/// Adaptively decides which stream positions are "worth keeping",
/// using cross-track deviation (not raw bearing diff) to detect curves.
/// This makes it robust to GPS jitter on straight paths, since a noisy
/// bearing over a short segment produces only a tiny perpendicular offset.
class AdaptiveLocationFilter {
  AdaptiveLocationFilter({
    this.straightLineDistanceThreshold = 30, // max gap on a straight path (m)
    this.curveTriggerDistance = 4,           // perpendicular deviation that means "curving" (m)
    this.minAcceptDistance = 3,              // drops GPS jitter/stationary noise (m)
    this.maxAcceptedAccuracy,                // optional: drop low-accuracy fixes (m)
    this.bearingSmoothing = 0.3,             // 0 = no smoothing, 1 = frozen reference
  });

  final double straightLineDistanceThreshold;
  final double curveTriggerDistance;
  final double minAcceptDistance;
  final double? maxAcceptedAccuracy;
  final double bearingSmoothing;

  Position? _lastAccepted;
  double? _referenceBearing; // smoothed direction of travel

  bool shouldAccept(Position newPos) {
    if (maxAcceptedAccuracy != null && newPos.accuracy > maxAcceptedAccuracy!) {
      return false;
    }

    if (_lastAccepted == null) {
      _lastAccepted = newPos;
      return true;
    }

    final distance = Geolocator.distanceBetween(
      _lastAccepted!.latitude,
      _lastAccepted!.longitude,
      newPos.latitude,
      newPos.longitude,
    );

    if (distance < minAcceptDistance) return false;

    final bearingToNew = Geolocator.bearingBetween(
      _lastAccepted!.latitude,
      _lastAccepted!.longitude,
      newPos.latitude,
      newPos.longitude,
    );

    // No established direction yet (second-ever point) — accept and set it.
    if (_referenceBearing == null) {
      _lastAccepted = newPos;
      _referenceBearing = bearingToNew;
      return true;
    }

    final angleDiffRad = _angleDifference(_referenceBearing!, bearingToNew) * pi / 180;
    final crossTrackDistance = (distance * sin(angleDiffRad)).abs();

    if (crossTrackDistance >= curveTriggerDistance) {
      // Genuine curve: the path is bending away from the established line.
      _lastAccepted = newPos;
      _referenceBearing = bearingToNew; // snap fully to new direction on a real turn
      return true;
    }

    if (distance >= straightLineDistanceThreshold) {
      // Still basically straight, but far enough to checkpoint.
      _lastAccepted = newPos;
      // Smooth the reference bearing rather than snapping, so slow drift
      // (gentle bends) still gets tracked without over-reacting to jitter.
      _referenceBearing = _smoothBearing(_referenceBearing!, bearingToNew);
      return true;
    }

    return false;
  }

  double _smoothBearing(double current, double incoming) {
    final diff = _angleDifference(current, incoming);
    return (current + diff * (1 - bearingSmoothing)) % 360;
  }

  double _angleDifference(double a, double b) {
    double diff = (b - a) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    return diff;
  }

  void reset() {
    _lastAccepted = null;
    _referenceBearing = null;
  }
}