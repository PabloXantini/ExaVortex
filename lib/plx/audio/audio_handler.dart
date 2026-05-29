import 'package:exa_vortex/plx/core/logger.dart';
import 'audio_core.dart';
import 'audio_manager.dart';

class AudioHandler {
  PlxSoundHandle? _currentSoundtrack;
  PlxAudioSource? _currentSoundtrackSource;

  final Map<String, PlxAudioSource> _audioCache = {};

  AudioHandler();

  /// Precarga un sonido en caché
  Future<void> preload(String id, String assetPath) async {
    if (_audioCache.containsKey(id)) return;
    final source = await AudioManager.instance.loadAsset(assetPath);
    _audioCache[id] = source;
  }

  /// Reproduce un soundtrack en bucle, deteniendo el anterior si existe
  Future<void> playSoundtrack(String id, {double volume = 0.5}) async {
    if (!_audioCache.containsKey(id)) {
      PlxLogger.warning('Soundtrack $id not found in cache. Call preload first.', system: 'Audio');
      return;
    }

    if (_currentSoundtrack != null) {
      AudioManager.instance.stop(_currentSoundtrack!);
    }

    _currentSoundtrackSource = _audioCache[id];
    if (_currentSoundtrackSource != null) {
      _currentSoundtrack = await AudioManager.instance.play(
        _currentSoundtrackSource!,
        volume: volume,
        looping: true,
      );
    }
  }

  /// Detiene el soundtrack actual
  void stopSoundtrack() {
    if (_currentSoundtrack == null) return;
    AudioManager.instance.stop(_currentSoundtrack!);
    _currentSoundtrack = null;
  }

  /// Pausa el soundtrack actual
  void pauseSoundtrack() {
    if (_currentSoundtrack == null) return;
    AudioManager.instance.setPause(_currentSoundtrack!, true);
  }

  /// Resume el soundtrack actual
  void resumeSoundtrack() {
    if (_currentSoundtrack == null) return;
    AudioManager.instance.setPause(_currentSoundtrack!, false);
  }

  /// Cambia el volumen del soundtrack
  void setSoundtrackVolume(double volume) {
    if (_currentSoundtrack == null) return;
    AudioManager.instance.setVolume(_currentSoundtrack!, volume);
  }

  /// Reproduce un efecto de sonido global 2D (ej. UI)
  Future<PlxSoundHandle?> playSound(String id, {double volume = 1.0, double pitch = 1.0}) async {
    if (!_audioCache.containsKey(id)) {
      PlxLogger.warning('Sound $id not found in cache. Call preload first.', system: 'Audio');
      return null;
    }
    
    final handle = await AudioManager.instance.play(
      _audioCache[id]!,
      volume: volume,
    );
    
    if (pitch != 1.0) {
      AudioManager.instance.modPlaySpeed(handle, pitch);
    }
    
    return handle;
  }

  /// Limpia los recursos cargados por este handler
  void dispose() {
    stopSoundtrack();
    /*
    for (var source in _audioCache.values) {
      AudioManager.instance.disposeSource(source);
    }
    */
    // Removed: AudioManager.instance.disposeSource(source);
    // Doing so crashes the next scene if it shares the same audio file, 
    // as SoLoud destroys the underlying memory.
    _audioCache.clear();
  }
}
