import 'package:vector_math/vector_math_64.dart';
import '../level_metadata.dart';

LevelMetadata getExagonPlusLevel() {
  return LevelMetadata(
    id: 'lvl_exagon_plus',
    title: 'EXAGON PLUS',
    difficulty: 'Hyper (Hard)',
    song: 'shape_whirlwinds',
    sides: 6,
    baseRotationSpeed: 2.0,
    colorPalette: [
      Vector4(0.12, 0.02, 0.02, 1.0), // Deep red 1
      Vector4(0.18, 0.03, 0.03, 1.0), // Deep red 2
      Vector4(1.0, 0.1, 0.1, 1.0),    // Hyper neon red for active elements
    ],
    level: Level(
      phases: [
        // Phase 1: High speed patterns
        Phase(
          name: 'Phase 1: Hyper Velocity',
          duration: 15.0,
          rotationSpeed: 3.5,
          direction: 1,
          patterns: [
            Pattern(
              name: 'Hyper Spiral Left',
              walls: [
                Wall(side: 5, thickness: 0.2, spawnTime: 0.3, speed: 3.8),
                Wall(side: 4, thickness: 0.2, spawnTime: 0.6, speed: 3.8),
                Wall(side: 3, thickness: 0.2, spawnTime: 0.9, speed: 3.8),
                Wall(side: 2, thickness: 0.2, spawnTime: 1.2, speed: 3.8),
                Wall(side: 1, thickness: 0.2, spawnTime: 1.5, speed: 3.8),
                Wall(side: 0, thickness: 0.2, spawnTime: 1.8, speed: 3.8),
              ],
            ),
            Pattern(
              name: 'Intense Gate Alternations',
              walls: [
                // Gap at 2
                Wall(side: 0, thickness: 0.2, spawnTime: 4.0, speed: 4.0),
                Wall(side: 1, thickness: 0.2, spawnTime: 4.0, speed: 4.0),
                Wall(side: 3, thickness: 0.2, spawnTime: 4.0, speed: 4.0),
                Wall(side: 4, thickness: 0.2, spawnTime: 4.0, speed: 4.0),
                Wall(side: 5, thickness: 0.2, spawnTime: 4.0, speed: 4.0),

                // Gap at 5
                Wall(side: 0, thickness: 0.2, spawnTime: 4.5, speed: 4.0),
                Wall(side: 1, thickness: 0.2, spawnTime: 4.5, speed: 4.0),
                Wall(side: 2, thickness: 0.2, spawnTime: 4.5, speed: 4.0),
                Wall(side: 3, thickness: 0.2, spawnTime: 4.5, speed: 4.0),
                Wall(side: 4, thickness: 0.2, spawnTime: 4.5, speed: 4.0),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
