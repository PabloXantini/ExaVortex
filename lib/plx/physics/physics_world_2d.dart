import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/physics/2d/broadphase/quad_tree.dart';
import 'package:exa_vortex/plx/physics/2d/broadphase/spatial_hash_grid.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/collider_2d.dart';
import 'package:exa_vortex/plx/physics/2d/narrowphase/sat_solver.dart';
import 'package:exa_vortex/plx/physics/2d/resolution/collision_resolver.dart';

enum BroadPhaseType {
  spatialHash,
  quadTree,
}

class PhysicsWorld2D {
  final List<Collider2D> _colliders = [];
  
  final SpatialHashGrid _spatialGrid = SpatialHashGrid(cellSize: 100.0);
  late final QuadTree _quadTree;
  
  Vector2 gravity = Vector2(0.0, 9.81);
  BroadPhaseType broadPhaseType = BroadPhaseType.spatialHash;
  bool useCCD = true;

  PhysicsWorld2D({Aabb2? worldBounds}) {
    _quadTree = QuadTree(
      level: 0,
      bounds: worldBounds ?? Aabb2.minMax(Vector2(-1000, -1000), Vector2(1000, 1000)),
    );
  }

  void addCollider(Collider2D collider) {
    _colliders.add(collider);
    if (broadPhaseType == BroadPhaseType.spatialHash) {
      _spatialGrid.insert(collider);
    }
  }

  void removeCollider(Collider2D collider) {
    _colliders.remove(collider);
    if (broadPhaseType == BroadPhaseType.spatialHash) {
      _spatialGrid.remove(collider);
    }
  }

  void step(double dt) {
    if (dt <= 0.0) return;

    // 1. Integration (Apply forces, update velocities and positions)
    for (final c in _colliders) {
      if (!c.isStatic) {
        c.velocity += gravity * dt;
        c.position += c.velocity * dt;
      }
    }

    // 2. Broad Phase Update
    List<List<Collider2D>> potentialPairs = [];
    
    if (broadPhaseType == BroadPhaseType.spatialHash) {
      // Simplest update is to clear and re-insert. 
      // More advanced: only update moved colliders.
      _spatialGrid.clear();
      for (final c in _colliders) {
        _spatialGrid.insert(c);
      }
      potentialPairs = _spatialGrid.getAllPotentialCollisionPairs();
    } else {
      _quadTree.clear();
      for (final c in _colliders) {
        _quadTree.insert(c);
      }
      
      final checked = <String>{};
      for (final c in _colliders) {
        final potentials = <Collider2D>[];
        _quadTree.retrieve(potentials, c);
        
        for (final other in potentials) {
          if (c == other) continue;
          
          final hash1 = c.hashCode;
          final hash2 = other.hashCode;
          final pairHash = hash1 < hash2 ? '$hash1-$hash2' : '$hash2-$hash1';

          if (!checked.contains(pairHash)) {
            checked.add(pairHash);
            potentialPairs.add([c, other]);
          }
        }
      }
    }

    // 3. Narrow Phase (SAT) and Resolution
    for (final pair in potentialPairs) {
      final a = pair[0];
      final b = pair[1];

      // Ignore if both are static
      if (a.isStatic && b.isStatic) continue;

      final manifold = SATSolver.test(a, b, dt: useCCD ? dt : 0.0);
      
      if (manifold != null) {
        if (useCCD && manifold.timeOfImpact > 0.0) {
          // Predictive/Speculative resolution
          CollisionResolver.resolveSpeculativeContacts(manifold, dt);
        } else {
          // Discrete resolution
          CollisionResolver.resolveVelocity(manifold);
          CollisionResolver.positionalCorrection(manifold);
        }
      }
    }
  }
}
