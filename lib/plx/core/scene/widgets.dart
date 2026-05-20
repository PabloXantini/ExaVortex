import 'package:flutter/material.dart';
import 'scene_manager.dart';

/// WidgetBuilder for Scene Transitions.
/// 
/// * [context] The build context.
/// * [progress] The progress normalized (0.0 to 1.0) of the transition.
/// * [state] The state of the transition.
typedef PlxTransitionBuilder = Widget Function(
  BuildContext context, 
  double progress, 
  SceneTransitionState state
);
