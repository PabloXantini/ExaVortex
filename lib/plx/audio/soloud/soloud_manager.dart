import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:vector_math/vector_math_64.dart';
import '../audio_core.dart';

class SoloudAudioSource implements PlxAudioSource {
  final AudioSource source;
  SoloudAudioSource(this.source);
}

class SoloudSoundHandle implements PlxSoundHandle {
  final SoundHandle handle;
  SoloudSoundHandle(this.handle);
}

class SoloudAudioManager implements PlxAudioManager {
  bool _isInitialized = false;
  SoLoud? _soloud;
  AudioData? _audioData;

  SoLoud get soloud {
    if (_soloud == null) {
      throw Exception("SoloudAudioManager is not initialized");
    }
    return _soloud!;
  }

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _soloud = SoLoud.instance;
    if (!_soloud!.isInitialized) await _soloud!.init(bufferSize: 1024);
    _soloud!.setVisualizationEnabled(true);
    _audioData = AudioData(GetSamplesKind.linear);
    
    _isInitialized = true;
    debugPrint("SoloudAudioManager initialized with visualization enabled");
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _audioData?.dispose();
      _soloud?.deinit();
      _isInitialized = false;
      debugPrint("SoloudAudioManager disposed");
    }
  }

  @override
  Future<PlxAudioSource> loadAsset(String path) async {
    final source = await soloud.loadAsset(path);
    return SoloudAudioSource(source);
  }

  @override
  Future<PlxSoundHandle> play(
    PlxAudioSource source, {
    double volume = 1.0,
    double pan = 0.0,
    bool paused = false,
    bool looping = false,
  }) async {
    final soloudSource = (source as SoloudAudioSource).source;
    final handle = await soloud.play(
      soloudSource,
      volume: volume,
      pan: pan,
      paused: paused,
      looping: looping,
    );
    return SoloudSoundHandle(handle);
  }

  @override
  Future<PlxSoundHandle> play3d(
    PlxAudioSource source,
    Vector3 position, {
    Vector3? velocity,
    double volume = 1.0,
    bool paused = false,
    bool looping = false,
  }) async {
    final soloudSource = (source as SoloudAudioSource).source;
    final handle = await soloud.play3d(
      soloudSource,
      position.x, position.y, position.z,
      velX: velocity?.x ?? 0.0,
      velY: velocity?.y ?? 0.0,
      velZ: velocity?.z ?? 0.0,
      volume: volume,
      paused: paused,
      looping: looping,
    );
    return SoloudSoundHandle(handle);
  }

  @override
  void stop(PlxSoundHandle handle) {
    soloud.stop((handle as SoloudSoundHandle).handle);
  }

  @override
  void setPause(PlxSoundHandle handle, bool pause) {
    soloud.setPause((handle as SoloudSoundHandle).handle, pause);
  }

  @override
  void setVolume(PlxSoundHandle handle, double volume) {
    soloud.setVolume((handle as SoloudSoundHandle).handle, volume);
  }

  @override
  void setPan(PlxSoundHandle handle, double pan) {
    soloud.setPan((handle as SoloudSoundHandle).handle, pan);
  }

  @override
  void modPlaySpeed(PlxSoundHandle handle, double speed) {
    soloud.setRelativePlaySpeed((handle as SoloudSoundHandle).handle, speed);
  }

  @override
  void mod3dSource(PlxSoundHandle handle, Vector3 position, {Vector3? velocity}) {
    soloud.set3dSourceParameters(
      (handle as SoloudSoundHandle).handle,
      position.x, position.y, position.z,
      velocity?.x ?? 0.0, velocity?.y ?? 0.0, velocity?.z ?? 0.0,
    );
  }

  @override
  void mod3dListener(
    Vector3 position,
    Vector3 lookAt,
    Vector3 up, {
    Vector3? velocity,
  }) {
    soloud.set3dListenerParameters(
      position.x, position.y, position.z,
      lookAt.x, lookAt.y, lookAt.z,
      up.x, up.y, up.z,
      velocity?.x ?? 0.0, velocity?.y ?? 0.0, velocity?.z ?? 0.0,
    );
  }

  @override
  void update() {
    if (!_isInitialized) return;
    try {
      _audioData?.updateSamples();
    } catch (e) {
      debugPrint("Error updating audio samples: $e");
    }
  }

  @override
  void setFftSmoothing(double smoothing) {
    soloud.setFftSmoothing(smoothing);
  }

  @override
  Float32List getAudioData() {
    if (_audioData == null) return Float32List(512);
    return _audioData!.getAudioData();
  }

  @override
  void disposeSource(PlxAudioSource source) {
    soloud.disposeSource((source as SoloudAudioSource).source);
  }
}
