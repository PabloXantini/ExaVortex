import 'package:exa_vortex/plx/core/component.dart';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/audio/plx_audio.dart';

class AudioSource3D extends Component {
  final PlxAudioSource source;
  PlxSoundHandle? _handle;

  double _volume = 1.0;
  double _pitch = 1.0;
  bool _looping = false;
  bool _isPlaying = false;
  
  Vector3 velocity = Vector3.zero();

  AudioSource3D(this.source, {
    double volume = 1.0,
    double pitch = 1.0,
    bool looping = false,
  }) {
    _volume = volume;
    _pitch = pitch;
    _looping = looping;
  }

  double get volume => _volume;
  set volume(double val) {
    _volume = val;
    if (_handle != null) {
      AudioManager.instance.setVolume(_handle!, _volume);
    }
  }

  double get pitch => _pitch;
  set pitch(double val) {
    _pitch = val;
    if (_handle != null) {
      AudioManager.instance.modPlaySpeed(_handle!, _pitch);
    }
  }

  bool get isPlaying => _isPlaying;

  Future<void> play() async {
    if (_isPlaying) return;

    final transform = entity?.getComponent<TransformUser>();
    final position = transform?.position ?? Vector3.zero();

    _handle = await AudioManager.instance.play3d(
      source,
      position,
      velocity: velocity,
      volume: _volume,
      looping: _looping,
    );
    
    if (_pitch != 1.0) {
      AudioManager.instance.modPlaySpeed(_handle!, _pitch);
    }
    
    _isPlaying = true;
  }

  void stop() {
    if (_handle != null) {
      AudioManager.instance.stop(_handle!);
      _handle = null;
    }
    _isPlaying = false;
  }

  void pause() {
    if (_handle != null) {
      AudioManager.instance.setPause(_handle!, true);
    }
  }

  void resume() {
    if (_handle != null) {
      AudioManager.instance.setPause(_handle!, false);
    }
  }

  @override
  void update(double dt) {
    if (_isPlaying && _handle != null) {
      // Sync position
      final transform = entity?.getComponent<TransformUser>();
      if (transform != null) {
        AudioManager.instance.mod3dSource(
          _handle!,
          transform.position,
          velocity: velocity,
        );
      }
    }
  }

  @override
  void onRemoved() {
    stop();
    super.onRemoved();
  }
}
