import 'package:vector_math/vector_math_64.dart';
import '../level_metadata.dart';

LevelMetadata getHexagonFlightLevel() {
  return LevelMetadata(
    id: 'lvl_hexagon_flight',
    title: 'HEXAGON FLIGHT',
    difficulty: 'Point Zero (Easy)',
    song: 'shape_whirlwinds',
    sides: 6,
    baseRotationSpeed: 1.0,
    colorPalette: [
      Vector4(0.04, 0.08, 0.12, 1.0), // Deep blue-gray 1
      Vector4(0.07, 0.13, 0.20, 1.0), // Deep blue-gray 2
      Vector4(0.0, 0.8, 1.0, 1.0),    // Vibrant cyan for active elements
    ],
    level: Level(
      phases: [
        // Phase 1: Slow introduction spiral
        Phase(
          name: 'Phase 1: Spin Intro',
          duration: 15.0,
          rotationSpeed: 1.2,
          direction: 1,
          patterns: [
            Pattern(
              name: 'Slow Spiral Right',
              walls: [
                Wall(side: 0, thickness: 0.25, spawnTime: 1.0, speed: 2.0),
                Wall(side: 1, thickness: 0.25, spawnTime: 1.5, speed: 2.0),
                Wall(side: 2, thickness: 0.25, spawnTime: 2.0, speed: 2.0),
                Wall(side: 3, thickness: 0.25, spawnTime: 2.5, speed: 2.0),
                Wall(side: 4, thickness: 0.25, spawnTime: 3.0, speed: 2.0),
                Wall(side: 5, thickness: 0.25, spawnTime: 3.5, speed: 2.0),
              ],
            ),
            Pattern(
              name: 'Alternating Opposites',
              walls: [
                Wall(side: 0, thickness: 0.3, spawnTime: 6.0, speed: 2.0),
                Wall(side: 3, thickness: 0.3, spawnTime: 6.0, speed: 2.0),
                Wall(side: 1, thickness: 0.3, spawnTime: 8.0, speed: 2.0),
                Wall(side: 4, thickness: 0.3, spawnTime: 8.0, speed: 2.0),
                Wall(side: 2, thickness: 0.3, spawnTime: 10.0, speed: 2.0),
                Wall(side: 5, thickness: 0.3, spawnTime: 10.0, speed: 2.0),
              ],
            ),
          ],
        ),
        // Phase 2: C-rings (rings with 1 open side)
        Phase(
          name: 'Phase 2: Gateway',
          duration: 15.0,
          rotationSpeed: 1.5,
          direction: -1,
          patterns: [
            Pattern(
              name: 'C-Rings alternating',
              walls: [
                // Gap at side 0
                Wall(side: 1, thickness: 0.25, spawnTime: 1.0, speed: 2.2),
                Wall(side: 2, thickness: 0.25, spawnTime: 1.0, speed: 2.2),
                Wall(side: 3, thickness: 0.25, spawnTime: 1.0, speed: 2.2),
                Wall(side: 4, thickness: 0.25, spawnTime: 1.0, speed: 2.2),
                Wall(side: 5, thickness: 0.25, spawnTime: 1.0, speed: 2.2),
                
                // Gap at side 3
                Wall(side: 0, thickness: 0.25, spawnTime: 5.0, speed: 2.2),
                Wall(side: 1, thickness: 0.25, spawnTime: 5.0, speed: 2.2),
                Wall(side: 2, thickness: 0.25, spawnTime: 5.0, speed: 2.2),
                Wall(side: 4, thickness: 0.25, spawnTime: 5.0, speed: 2.2),
                Wall(side: 5, thickness: 0.25, spawnTime: 5.0, speed: 2.2),
                
                // Gap at side 1
                Wall(side: 0, thickness: 0.25, spawnTime: 9.0, speed: 2.2),
                Wall(side: 2, thickness: 0.25, spawnTime: 9.0, speed: 2.2),
                Wall(side: 3, thickness: 0.25, spawnTime: 9.0, speed: 2.2),
                Wall(side: 4, thickness: 0.25, spawnTime: 9.0, speed: 2.2),
                Wall(side: 5, thickness: 0.25, spawnTime: 9.0, speed: 2.2),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
