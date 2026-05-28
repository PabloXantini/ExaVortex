import 'package:exa_vortex/plx/math/plx_math.dart';
import 'package:exa_vortex/plx/physics/2d/colliders/collider_2d.dart';

class QuadTree {
  final int maxObjects;
  final int maxLevels;
  final int level;
  final Aabb2 bounds;

  final List<Collider2D> objects = [];
  final List<QuadTree?> nodes = List.filled(4, null);

  QuadTree({
    required this.level,
    required this.bounds,
    this.maxObjects = 10,
    this.maxLevels = 5,
  });

  /// Clear the quadtree
  void clear() {
    objects.clear();
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i] != null) {
        nodes[i]!.clear();
        nodes[i] = null;
      }
    }
  }

  /// Split the node into 4 subnodes
  void split() {
    final double subWidth = (bounds.max.x - bounds.min.x) / 2.0;
    final double subHeight = (bounds.max.y - bounds.min.y) / 2.0;
    final double x = bounds.min.x;
    final double y = bounds.min.y;

    nodes[0] = QuadTree(
      level: level + 1,
      bounds: Aabb2.minMax(Vector2(x + subWidth, y), Vector2(x + subWidth * 2, y + subHeight)),
      maxObjects: maxObjects,
      maxLevels: maxLevels,
    );
    nodes[1] = QuadTree(
      level: level + 1,
      bounds: Aabb2.minMax(Vector2(x, y), Vector2(x + subWidth, y + subHeight)),
      maxObjects: maxObjects,
      maxLevels: maxLevels,
    );
    nodes[2] = QuadTree(
      level: level + 1,
      bounds: Aabb2.minMax(Vector2(x, y + subHeight), Vector2(x + subWidth, y + subHeight * 2)),
      maxObjects: maxObjects,
      maxLevels: maxLevels,
    );
    nodes[3] = QuadTree(
      level: level + 1,
      bounds: Aabb2.minMax(Vector2(x + subWidth, y + subHeight), Vector2(x + subWidth * 2, y + subHeight * 2)),
      maxObjects: maxObjects,
      maxLevels: maxLevels,
    );
  }

  /// Determine which node the object belongs to. -1 means object cannot completely fit within a child node
  int getIndex(Collider2D collider) {
    int index = -1;
    final aabb = collider.aabb;
    
    final double verticalMidpoint = bounds.min.x + (bounds.max.x - bounds.min.x) / 2.0;
    final double horizontalMidpoint = bounds.min.y + (bounds.max.y - bounds.min.y) / 2.0;

    final bool topQuadrant = (aabb.min.y < horizontalMidpoint && aabb.max.y < horizontalMidpoint);
    final bool bottomQuadrant = (aabb.min.y > horizontalMidpoint);

    if (aabb.min.x < verticalMidpoint && aabb.max.x < verticalMidpoint) {
      if (topQuadrant) {
        index = 1;
      } else if (bottomQuadrant) {
        index = 2;
      }
    } else if (aabb.min.x > verticalMidpoint) {
      if (topQuadrant) {
        index = 0;
      } else if (bottomQuadrant) {
        index = 3;
      }
    }

    return index;
  }

  /// Insert the object into the quadtree
  void insert(Collider2D collider) {
    if (nodes[0] != null) {
      int index = getIndex(collider);
      if (index != -1) {
        nodes[index]!.insert(collider);
        return;
      }
    }

    objects.add(collider);

    if (objects.length > maxObjects && level < maxLevels) {
      if (nodes[0] == null) {
        split();
      }

      int i = 0;
      while (i < objects.length) {
        int index = getIndex(objects[i]);
        if (index != -1) {
          nodes[index]!.insert(objects.removeAt(i));
        } else {
          i++;
        }
      }
    }
  }

  /// Return all objects that could collide with the given object
  List<Collider2D> retrieve(List<Collider2D> returnObjects, Collider2D collider) {
    int index = getIndex(collider);
    if (index != -1 && nodes[0] != null) {
      nodes[index]!.retrieve(returnObjects, collider);
    } else if (nodes[0] != null) {
      // If object overlaps multiple quadrants, retrieve from all of them
      // Alternatively, could check intersection with each quadrant's bounds
      for (int i = 0; i < nodes.length; i++) {
        // A simple optimization: check AABB intersection before descending
        if (intersects(nodes[i]!.bounds, collider.aabb)) {
          nodes[i]!.retrieve(returnObjects, collider);
        }
      }
    }

    returnObjects.addAll(objects);
    return returnObjects;
  }

  bool intersects(Aabb2 a, Aabb2 b) {
    return (a.min.x <= b.max.x && a.max.x >= b.min.x) &&
           (a.min.y <= b.max.y && a.max.y >= b.min.y);
  }
}
