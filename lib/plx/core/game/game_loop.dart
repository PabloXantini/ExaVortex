import 'package:flutter/scheduler.dart';

class PlxGameLoop {
  final void Function(double dt) onTick;
  late final Ticker _ticker;
  double _lastTime = 0.0;

  PlxGameLoop({required this.onTick, required TickerProvider vsync}) {
    _ticker = vsync.createTicker(_tick);
  }

  void _tick(Duration elapsed) {
    double time = elapsed.inMicroseconds / 1000000.0;
    double dt = time - _lastTime;
    _lastTime = time;
    onTick(dt);
  }

  void start() {
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
  }

  void dispose() {
    _ticker.dispose();
  }
}
