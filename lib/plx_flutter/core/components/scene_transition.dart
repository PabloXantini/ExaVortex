import '../game_scene.dart';
import '../scene_manager.dart';
import 'component.dart';

class SceneTransition extends Component {
  final GameScene targetScene;
  final double delay;
  final double duration;
  double _timer = 0.0;
  bool _triggered = false;

  SceneTransition({
    required this.targetScene, 
    this.delay = 0.0,
    this.duration = 0.5,
  });

  @override
  void update(double dt) {
    if (_triggered) return;
    
    _timer += dt;
    if (_timer >= delay) {
      _triggered = true;
      SceneManager().changeScene(targetScene, duration: duration);
    }
  }
}
