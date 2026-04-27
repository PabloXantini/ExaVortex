import 'dart:ui';
import '../graphics/renderer.dart';
import 'entity.dart';

abstract class Component {
  Entity? entity;
  bool active = true;

  void onAdded() {}
  void onRemoved() {}

  void update(double dt) {}
  void draw(PlxRenderer renderer, Canvas canvas, Size size) {}
}
