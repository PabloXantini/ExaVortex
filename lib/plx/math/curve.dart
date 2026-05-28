import 'dart:math' as math;

/// Built-in easing curves shared by [PlxTween] and [PlxPointKeyFrame].
enum PlxCurve {
  linear,
  easeIn,
  easeOut,
  easeInOut,
  exponential,
  bounce,
}

/// Internal easing math. Not part of the public API.
abstract final class PlxCurveMath {
  static double apply(PlxCurve curve, double t) {
    switch (curve) {
      case PlxCurve.linear:
        return t;
      case PlxCurve.easeIn:
        return t * t;
      case PlxCurve.easeOut:
        return t * (2.0 - t);
      case PlxCurve.easeInOut:
        return t < 0.5 ? 2.0 * t * t : -1.0 + (4.0 - 2.0 * t) * t;
      case PlxCurve.exponential:
        if (t == 0.0) return 0.0;
        if (t == 1.0) return 1.0;
        return math.pow(2.0, 10.0 * (t - 1.0)).toDouble();
      case PlxCurve.bounce:
        return _bounce(t);
    }
  }

  static double _bounce(double t) {
    if (t < 1.0 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2.0 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    } else {
      t -= 2.625 / 2.75;
      return 7.5625 * t * t + 0.984375;
    }
  }
}
