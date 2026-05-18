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

  Future<void>? _initFuture;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;

    _initFuture = _doInit();
    return _initFuture;
  }
  Future<void> _doInit() async {
    _soloud = SoLoud.instance;
    try {
      await _soloud!.init(bufferSize: 1024);
    } catch (e) {
      if (e.toString().contains("AlreadyInitialized")) {
        debugPrint("SoLoud already initialized on native side.");
        await _soloud!.disposeAllSources();
      } else {
        _initFuture = null;
        rethrow;
        }
      }
    _soloud!.setVisualizationEnabled(true);
    _audioData = AudioData(GetSamplesKind.linear);
    _isInitialized = true;
    debugPrint("SoloudAudioManager initialized with visualization enabled");
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }
    await init();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    await _ensureInitialized();
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
    if (!_isInitialized) return;
    soloud.stop((handle as SoloudSoundHandle).handle);
  }

  @override
  void setPause(PlxSoundHandle handle, bool pause) {
    if (!_isInitialized) return;
    soloud.setPause((handle as SoloudSoundHandle).handle, pause);
  }

  @override
  void setVolume(PlxSoundHandle handle, double volume) {
    if (!_isInitialized) return;
    soloud.setVolume((handle as SoloudSoundHandle).handle, volume);
  }

  @override
  void setPan(PlxSoundHandle handle, double pan) {
    if (!_isInitialized) return;
    soloud.setPan((handle as SoloudSoundHandle).handle, pan);
  }

  @override
  void modPlaySpeed(PlxSoundHandle handle, double speed) {
    if (!_isInitialized) return;
    soloud.setRelativePlaySpeed((handle as SoloudSoundHandle).handle, speed);
  }

  @override
  void mod3dSource(PlxSoundHandle handle, Vector3 position, {Vector3? velocity}) {
    if (!_isInitialized) return;
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
    if (!_isInitialized) return;
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
    if (!_isInitialized) return;
    soloud.setFftSmoothing(smoothing);
  }

  @override
  Float32List getAudioData() {
    if (!_isInitialized || _audioData == null) return Float32List(512);
    return _audioData!.getAudioData();
  }

  @override
  void disposeSource(PlxAudioSource source) {
    if (!_isInitialized) return;
    soloud.disposeSource((source as SoloudAudioSource).source);
  }
}
