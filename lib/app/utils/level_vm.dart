import 'level_metadata.dart';

class ActiveWall {
  final Wall wall;
  double distance; // Inner distance from the center (shrinks over time)

  ActiveWall({
    required this.wall,
    required this.distance,
  });
}

class LevelVM {
  final Level level;

  double phaseTime = 0.0;
  int currentPhaseIndex = 0;
  bool isFinished = false;

  // Obstacles currently active on screen
  final List<ActiveWall> activeWalls = [];

  // Tracks which walls in the current phase have already spawned
  final Set<Wall> spawnedWalls = {};

  LevelVM({required this.level});

  /// Resets the VM state to start fresh.
  void reset() {
    phaseTime = 0.0;
    currentPhaseIndex = 0;
    isFinished = false;
    activeWalls.clear();
    spawnedWalls.clear();
  }

  /// Get the current phase name.
  String get currentPhaseName {
    if (level.phases.isEmpty) return 'No Phase';
    return level.phases[currentPhaseIndex].name;
  }

  /// Get the current phase object.
  Phase? get currentPhase {
    if (level.phases.isEmpty) return null;
    return level.phases[currentPhaseIndex];
  }

  /// Updates the VM timers, triggers spawns, and shrinks active walls.
  void update(double dt, {required double startDistance, required double minDistance}) {
    if (level.phases.isEmpty) {
      isFinished = true;
      return;
    }

    phaseTime += dt;
    final currentPhase = level.phases[currentPhaseIndex];

    // Check if phase is over, move to next phase
    if (phaseTime >= currentPhase.duration) {
      phaseTime = 0.0;
      currentPhaseIndex++;
      spawnedWalls.clear();

      if (currentPhaseIndex >= level.phases.length) {
        // Wrap around to loop the level phases or keep them looping
        currentPhaseIndex = 0;
      }
    }

    // Evaluate spawning of walls
    for (var pattern in currentPhase.patterns) {
      for (var wall in pattern.walls) {
        if (phaseTime >= wall.spawnTime && !spawnedWalls.contains(wall)) {
          spawnedWalls.add(wall);
          activeWalls.add(ActiveWall(
            wall: wall,
            distance: startDistance,
          ));
        }
      }
    }

    // Update active walls distance (animate them shrinking inwards)
    for (int i = activeWalls.length - 1; i >= 0; i--) {
      final active = activeWalls[i];
      active.distance -= active.wall.speed * dt;

      // Clean up walls that have fully shrunk past the minimum gameplay boundary
      if (active.distance + active.wall.thickness < minDistance) {
        activeWalls.removeAt(i);
      }
    }
  }
}
