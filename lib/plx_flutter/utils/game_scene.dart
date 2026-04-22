import 'dart:ffi';

abstract class GameScene {
  void onInit();
  void onClose();
  void show();
  void update(Float dt);
}
