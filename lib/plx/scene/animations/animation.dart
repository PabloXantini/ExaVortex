/// Abstract base class for all dt-driven animations.
///
/// Subclasses: [PlxTween] (curve-based), [PlxAnimKeyFrame] (keyframe-based).
/// Animations are updated manually via [update] in the game loop and
/// are general-purpose — usable for both UI overlays and entity logic.
abstract class PlxAnimation {
  /// Normalized output value, typically in the range 0.0 to 1.0.
  double get value;

  /// Whether the animation has reached its end state in the current direction.
  bool get isCompleted;

  /// Whether the animation is actively progressing.
  bool get isRunning;

  /// Plays the animation forward (0.0 → 1.0).
  void forward();

  /// Plays the animation in reverse (1.0 → 0.0).
  void reverse();

  /// Resets the animation to its initial state (value = 0.0, stopped).
  void reset();

  /// Advances the animation by [dt] seconds. Call this from the game loop.
  void update(double dt);

  /// Releases any held resources. Call this when the animation is no longer needed.
  void dispose();
}
