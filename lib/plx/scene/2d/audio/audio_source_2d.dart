import 'package:exa_vortex/plx/core/component.dart';
import 'package:exa_vortex/plx/audio/plx_audio.dart';

class AudioSource2D extends Component {
  final PlxAudioSource source;
  PlxSoundHandle? _handle;

  double _volume = 1.0;
  double _pitch = 1.0;
  double _pan = 0.0;
  bool _looping = false;
  bool _isPlaying = false;

  AudioSource2D(this.source, {
    double volume = 1.0,
    double pitch = 1.0,
    double pan = 0.0,
    bool looping = false,
  }) {
    _volume = volume;
    _pitch = pitch;
    _pan = pan;
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

  double get pan => _pan;
  set pan(double val) {
    _pan = val.clamp(-1.0, 1.0);
    if (_handle != null) {
      AudioManager.instance.setPan(_handle!, _pan);
    }
  }

  bool get isPlaying => _isPlaying;

  Future<void> play() async {
    if (_isPlaying) return;

    _handle = await AudioManager.instance.play(
      source,
      volume: _volume,
      pan: _pan,
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
  void onRemoved() {
    stop();
    super.onRemoved();
  }
}
