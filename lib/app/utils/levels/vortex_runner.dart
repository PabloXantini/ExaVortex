import 'package:vector_math/vector_math_64.dart';
import '../level_metadata.dart';

LevelMetadata getVortexRunnerLevel() {
  return LevelMetadata(
    id: 'lvl_vortex_runner',
    title: 'VORTEX RUNNER',
    difficulty: 'Standard (Medium)',
    song: 'shape_whirlwinds',
    sides: 6,
    baseRotationSpeed: 1.5,
    colorPalette: [
      Vector4(0.08, 0.03, 0.12, 1.0), // Deep purple 1
      Vector4(0.14, 0.05, 0.20, 1.0), // Deep purple 2
      Vector4(1.0, 0.0, 0.6, 1.0),    // Neon pink/magenta for active elements
    ],
    level: Level(
      phases: [
        // Phase 1: Fast alternating patterns
        Phase(
          name: 'Phase 1: Shift Rhythm',
          duration: 15.0,
          rotationSpeed: 2.0,
          direction: 1,
          patterns: [
            Pattern(
              name: 'Fast Alternates',
              walls: [
                Wall(side: 0, thickness: 0.2, spawnTime: 0.5, speed: 2.8),
                Wall(side: 2, thickness: 0.2, spawnTime: 1.0, speed: 2.8),
                Wall(side: 4, thickness: 0.2, spawnTime: 1.5, speed: 2.8),
                Wall(side: 1, thickness: 0.2, spawnTime: 2.0, speed: 2.8),
                Wall(side: 3, thickness: 0.2, spawnTime: 2.5, speed: 2.8),
                Wall(side: 5, thickness: 0.2, spawnTime: 3.0, speed: 2.8),
              ],
            ),
            Pattern(
              name: 'Double Blocks',
              walls: [
                Wall(side: 0, thickness: 0.2, spawnTime: 5.0, speed: 3.0),
                Wall(side: 1, thickness: 0.2, spawnTime: 5.0, speed: 3.0),
                Wall(side: 3, thickness: 0.2, spawnTime: 7.0, speed: 3.0),
                Wall(side: 4, thickness: 0.2, spawnTime: 7.0, speed: 3.0),
                Wall(side: 2, thickness: 0.2, spawnTime: 9.0, speed: 3.0),
                Wall(side: 3, thickness: 0.2, spawnTime: 9.0, speed: 3.0),
              ],
            ),
          ],
        ),
        // Phase 2: Double gaps and speed
        Phase(
          name: 'Phase 2: Speed Gate',
          duration: 15.0,
          rotationSpeed: 2.5,
          direction: -1,
          patterns: [
            Pattern(
              name: 'Opposing Gaps',
              walls: [
                // Gaps at 0 and 3
                Wall(side: 1, thickness: 0.25, spawnTime: 1.0, speed: 3.2),
                Wall(side: 2, thickness: 0.25, spawnTime: 1.0, speed: 3.2),
                Wall(side: 4, thickness: 0.25, spawnTime: 1.0, speed: 3.2),
                Wall(side: 5, thickness: 0.25, spawnTime: 1.0, speed: 3.2),
                
                // Gaps at 1 and 4
                Wall(side: 0, thickness: 0.25, spawnTime: 4.5, speed: 3.2),
                Wall(side: 2, thickness: 0.25, spawnTime: 4.5, speed: 3.2),
                Wall(side: 3, thickness: 0.25, spawnTime: 4.5, speed: 3.2),
                Wall(side: 5, thickness: 0.25, spawnTime: 4.5, speed: 3.2),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
