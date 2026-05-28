import 'dart:collection';
import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/collider_2d.dart';

class SpatialHashGrid {
  final double cellSize;
  final Map<String, List<Collider2D>> _buckets = HashMap();

  SpatialHashGrid({this.cellSize = 50.0});

  /// Hash function to convert 2D grid coordinates to a string key
  String _hash(int x, int y) {
    return '$x,$y';
  }

  /// Helper to get all grid keys covered by an AABB
  List<String> _getKeysForAabb(Aabb2 aabb) {
    final keys = <String>[];
    
    int startX = (aabb.min.x / cellSize).floor();
    int startY = (aabb.min.y / cellSize).floor();
    int endX = (aabb.max.x / cellSize).floor();
    int endY = (aabb.max.y / cellSize).floor();

    for (int x = startX; x <= endX; x++) {
      for (int y = startY; y <= endY; y++) {
        keys.add(_hash(x, y));
      }
    }
    return keys;
  }

  /// Insert a collider into the grid
  void insert(Collider2D collider) {
    final aabb = collider.aabb;
    final keys = _getKeysForAabb(aabb);

    for (final key in keys) {
      if (!_buckets.containsKey(key)) {
        _buckets[key] = [];
      }
      _buckets[key]!.add(collider);
    }
  }

  /// Remove a collider from the grid
  void remove(Collider2D collider) {
    final aabb = collider.aabb;
    final keys = _getKeysForAabb(aabb);

    for (final key in keys) {
      _buckets[key]?.remove(collider);
    }
  }

  /// Update a collider's position in the grid (removes and re-inserts)
  /// Ideally, you'd cache the previous AABB keys to avoid re-calculating if not moved much.
  void update(Collider2D collider, Aabb2 oldAabb) {
    final oldKeys = _getKeysForAabb(oldAabb);
    for (final key in oldKeys) {
      _buckets[key]?.remove(collider);
    }
    insert(collider);
  }

  /// Clear the entire grid
  void clear() {
    _buckets.clear();
  }

  /// Get potential collisions for a given collider based on its AABB
  Set<Collider2D> getPotentialCollisions(Collider2D collider) {
    final aabb = collider.aabb;
    final keys = _getKeysForAabb(aabb);
    final potentials = <Collider2D>{};

    for (final key in keys) {
      if (_buckets.containsKey(key)) {
        for (final other in _buckets[key]!) {
          if (other != collider) {
            potentials.add(other);
          }
        }
      }
    }
    return potentials;
  }

  /// Get all unique pairs of potential collisions in the grid
  List<List<Collider2D>> getAllPotentialCollisionPairs() {
    final pairs = <List<Collider2D>>[];
    final checked = <String>{};

    for (final bucket in _buckets.values) {
      for (int i = 0; i < bucket.length; i++) {
        for (int j = i + 1; j < bucket.length; j++) {
          final c1 = bucket[i];
          final c2 = bucket[j];
          
          // Ensure consistent ordering to avoid duplicate pairs
          final hash1 = c1.hashCode;
          final hash2 = c2.hashCode;
          final pairHash = hash1 < hash2 ? '$hash1-$hash2' : '$hash2-$hash1';

          if (!checked.contains(pairHash)) {
            checked.add(pairHash);
            pairs.add([c1, c2]);
          }
        }
      }
    }
    return pairs;
  }
}
