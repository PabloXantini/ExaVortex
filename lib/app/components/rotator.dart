import 'dart:ui';

import 'package:exa_vortex/plx/core/plx_core.dart';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:flutter/material.dart';

/// A component that rotates an entity with a velocity vector
class Rotator extends Component{
  Vector3 minAngle = Vector3.all(double.negativeInfinity);
  Vector3 maxAngle = Vector3.all(double.infinity);
  Vector3 speed = Vector3.all(1.0);
  Rotator();
  Rotator.fromSpeed({Vector3? speed, Vector3? min, Vector3? max}) : 
    speed = speed ?? Vector3.all(1.0),
    minAngle = min ?? Vector3.all(double.negativeInfinity),
    maxAngle = max ?? Vector3.all(double.infinity);
  
  @override
  void update(double dt) {
    if (entity==null || speed==Vector3.zero()) return;
    final transform = entity!.getComponent<TransformUser>();
    if (speed.x!=0) transform?.rotation.x = clampDouble(transform.rotation.x + speed.x * dt, radians(minAngle.x), radians(maxAngle.x));
    if (speed.y!=0) transform?.rotation.y = clampDouble(transform.rotation.y + speed.y * dt, radians(minAngle.y), radians(maxAngle.y));
    if (speed.z!=0) transform?.rotation.z = clampDouble(transform.rotation.z + speed.z * dt, radians(minAngle.z), radians(maxAngle.z));
    //debugPrint('Rotation: ${transform?.rotation}');
    transform?.isDirty = true;
    super.update(dt);
  }
}