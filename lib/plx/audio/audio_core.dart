import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';

/// Class that wraps the audio source
abstract class PlxAudioSource {}

/// Interface that wraps the audio controllers
abstract class PlxSoundHandle {}

/// Interface for AudioManager backend
abstract class PlxAudioManager {
  Future<void> init();
  void dispose();

  Future<PlxAudioSource> loadAsset(String path);

  Future<PlxSoundHandle> play(
    PlxAudioSource source, {
    double volume = 1.0,
    double pan = 0.0,
    bool paused = false,
    bool looping = false,
  });

  Future<PlxSoundHandle> play3d(
    PlxAudioSource source,
    Vector3 position, {
    Vector3? velocity,
    double volume = 1.0,
    bool paused = false,
    bool looping = false,
  });

  void stop(PlxSoundHandle handle);
  void setPause(PlxSoundHandle handle, bool pause);
  void setVolume(PlxSoundHandle handle, double volume);
  void setPan(PlxSoundHandle handle, double pan);
  void modPlaySpeed(PlxSoundHandle handle, double speed);

  void mod3dSource(PlxSoundHandle handle, Vector3 position, {Vector3? velocity});
  void mod3dListener(
    Vector3 position,
    Vector3 lookAt,
    Vector3 up, {
    Vector3? velocity,
  });
  
  void update();

  void setFftSmoothing(double smoothing);

  /// Returns a Float32List containing audio samples.
  /// If linear kind is used, first 256 are FFT, next 256 are wave.
  Float32List getAudioData();

  void disposeSource(PlxAudioSource source);
}
