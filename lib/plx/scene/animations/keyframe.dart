import 'package:exa_vortex/plx/math/curve.dart';
import 'animation.dart';

export 'package:exa_vortex/plx/math/curve.dart' show PlxCurve;

/// A single (time, value) control point for [PlxPointKeyFrame].
///
/// Both [time] and [value] are in normalized [0.0, 1.0] space by convention,
/// but [value] can exceed that range to achieve overshoot effects.
class Keyframe {
  /// Normalized time position in [0.0, 1.0].
  final double time;

  /// Output value at this time. May exceed [0.0, 1.0] for overshoot.
  final double value;

  const Keyframe({required this.time, required this.value});
}

/// A keyframe-based animation that derives from [PlxAnimation].
///
/// Defined by a list of [Keyframe] control points. Each point maps a normalized
/// time in [0.0, 1.0] to an output value. The segment between consecutive
/// keyframes is interpolated using [segmentCurve].
///
/// Example:
/// ```dart
/// final anim = PlxAnimKeyFrame(
///   duration: 1.0,
///   keyframes: [
///     Keyframe(time: 0.0, value: 0.0),
///     Keyframe(time: 0.3, value: 1.2), // overshoot
///     Keyframe(time: 1.0, value: 1.0),
///   ],
/// );
/// anim.forward();
/// ```
class PlxAnimKeyFrame extends PlxAnimation {
  /// Total duration of the animation in seconds.
  final double duration;

  /// Control points. Will be sorted by time internally.
  final List<Keyframe> keyframes;

  /// Easing curve applied within each segment between consecutive keyframes.
  final PlxCurve segmentCurve;

  /// Whether the animation restarts after completing.
  final bool loop;

  double _progress = 0.0;
  bool _forward = true;
  bool _running = false;
  late final List<Keyframe> _sorted;

  PlxAnimKeyFrame({
    required this.duration,
    required this.keyframes,
    this.segmentCurve = PlxCurve.linear,
    this.loop = false,
  })  : assert(duration > 0, 'PlxAnimKeyFrame duration must be > 0'),
        assert(keyframes.length >= 2, 'PlxAnimKeyFrame needs at least 2 keyframes') {
    _sorted = List<Keyframe>.of(keyframes)
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  double get value => _evaluate(_progress);

  @override
  bool get isCompleted {
    if (_forward) return _progress >= 1.0;
    return _progress <= 0.0;
  }

  @override
  bool get isRunning => _running;

  @override
  void forward() {
    _forward = true;
    _running = true;
  }

  @override
  void reverse() {
    _forward = false;
    _running = true;
  }

  @override
  void reset() {
    _progress = 0.0;
    _running = false;
    _forward = true;
  }

  @override
  void update(double dt) {
    if (!_running) return;
    final step = dt / duration;
    if (_forward) {
      _progress += step;
      if (_progress >= 1.0) {
        _progress = loop ? _progress - 1.0 : 1.0;
        if (!loop) _running = false;
      }
    } else {
      _progress -= step;
      if (_progress <= 0.0) {
        _progress = loop ? _progress + 1.0 : 0.0;
        if (!loop) _running = false;
      }
    }
  }

  @override
  void dispose() {}

  double _evaluate(double t) {
    // Clamp to edges
    if (t <= _sorted.first.time) return _sorted.first.value;
    if (t >= _sorted.last.time) return _sorted.last.value;

    // Find surrounding keyframe pair
    for (int i = 0; i < _sorted.length - 1; i++) {
      final kA = _sorted[i];
      final kB = _sorted[i + 1];
      if (t >= kA.time && t <= kB.time) {
        final segmentSpan = kB.time - kA.time;
        if (segmentSpan == 0.0) return kA.value;
        // Local normalized t within this segment
        final localT = (t - kA.time) / segmentSpan;
        final curved = PlxCurveMath.apply(segmentCurve, localT);
        return kA.value + (kB.value - kA.value) * curved;
      }
    }
    return _sorted.last.value;
  }
}
