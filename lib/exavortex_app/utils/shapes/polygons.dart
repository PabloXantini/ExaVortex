import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class Polygon2D {
  List<Vector2>? vertices;
}

class RegularPolygon2D extends Polygon2D {
  int numvertices;
  double radius;
  RegularPolygon2D({
    required this.numvertices,
    required this.radius
  }){
    vertices = [];
    double tx = 2 * pi / numvertices;
    for (int i = 0; i < numvertices; i++) {
      double x = radius * cos(tx * i);
      double y = radius * sin(tx * i);
      vertices?.add(Vector2(x, y));
      debugPrint('$x $y');
    }
  }
  int get vnum => numvertices;
  double get r => radius;
}

class CustomPolygon2D extends Polygon2D {
  CustomPolygon2D({
    required List<Vector2> verts
  }){
    vertices = verts;
  }
}