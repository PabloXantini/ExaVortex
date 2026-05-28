import '../../math/curve.dart';
import 'animation.dart';

export '../../math/curve.dart' show PlxCurve; // expose PlxCurve as part of public API

/// A duration-based, curve-driven animation that derives from [PlxAnimation].
///
/// Progress is advanced by [update] calls from the game loop.
/// Apply an easing via [PlxCurve] to shape the output [value].
///
/// Example:
/// ```dart
/// final anim = PlxTween(duration: 0.5, curve: PlxCurve.easeOut);
/// anim.forward();
/// // in update(dt): anim.update(dt); refreshUI();
/// ```
class PlxTween extends PlxAnimation {
  /// Total duration of the animation in seconds.
  final double duration;

  /// Easing curve applied to the raw progress before [value] is computed.
  final PlxCurve curve;

  double _progress = 0.0; // raw normalized progress 0.0 → 1.0
  bool _forward = true;
  bool _running = false;

  PlxTween({
    required this.duration,
    this.curve = PlxCurve.linear,
  }) : assert(duration > 0, 'PlxTween duration must be > 0');

  @override
  double get value => PlxCurveMath.apply(curve, _progress);

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
    if (!_running || duration <= 0) return;
    final step = dt / duration;
    if (_forward) {
      _progress = (_progress + step).clamp(0.0, 1.0);
      if (_progress >= 1.0) _running = false;
    } else {
      _progress = (_progress - step).clamp(0.0, 1.0);
      if (_progress <= 0.0) _running = false;
    }
  }

  @override
  void dispose() {}
}
