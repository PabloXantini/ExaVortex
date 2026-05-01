import 'audio_core.dart';
import 'soloud/soloud_manager.dart';

class AudioManager {
  static PlxAudioManager? _instance;

  static PlxAudioManager get instance {
    _instance ??= SoloudAudioManager();
    return _instance!;
  }

  static set instance(PlxAudioManager manager) {
    _instance = manager;
  }
}

