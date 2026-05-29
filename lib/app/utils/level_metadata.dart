import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:exa_vortex/plx/core/logger.dart';
import 'package:exa_vortex/app/utils/levels/hexagon_flight.dart';
import 'package:exa_vortex/app/utils/levels/vortex_runner.dart';
import 'package:exa_vortex/app/utils/levels/exagon_plus.dart';

class Session {
  final String userId;
  final Map<String, int> scores; // Copy of scores: {level_id: bestScore}

  Session({
    required this.userId,
    required this.scores,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'scores': scores,
      };

  factory Session.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'] ?? json['nube'] ?? {};
    return Session(
      userId: json['user_id'] ?? 'PabloXantini',
      scores: Map<String, int>.from(rawScores),
    );
  }
}

class UserMetadata {
  final Session session;
  final String levelId;
  final int bestScore;
  final double bestTime; // Survival time in seconds

  UserMetadata({
    required this.session,
    required this.levelId,
    required this.bestScore,
    required this.bestTime,
  });

  Map<String, dynamic> toJson() => {
        'session': session.toJson(),
        'level_id': levelId,
        'bestScore': bestScore,
        'bestTime': bestTime,
      };

  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
      session: Session.fromJson(json['session'] ?? {}),
      levelId: json['level_id'] ?? '',
      bestScore: json['bestScore'] ?? 0,
      bestTime: (json['bestTime'] ?? 0.0).toDouble(),
    );
  }
}


class Wall {
  final int side; // Index of the segment/side (e.g., 0 to 5)
  final double thickness; // Length of the wall along the radial axis (e.g. 0.3)
  final double spawnTime; // When to spawn in seconds, relative to phase start
  final double speed; // Speed at which the wall moves inwards (e.g. 2.0 units/sec)

  Wall({
    required this.side,
    required this.thickness,
    required this.spawnTime,
    required this.speed,
  });

  Map<String, dynamic> toJson() => {
        'side': side,
        'thickness': thickness,
        'spawnTime': spawnTime,
        'speed': speed,
      };

  factory Wall.fromJson(Map<String, dynamic> json) {
    return Wall(
      side: json['side'] ?? 0,
      thickness: (json['thickness'] ?? 0.3).toDouble(),
      spawnTime: (json['spawnTime'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 2.5).toDouble(),
    );
  }
}

class Pattern {
  final String name;
  final List<Wall> walls;

  Pattern({
    required this.name,
    required this.walls,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'walls': walls.map((w) => w.toJson()).toList(),
      };

  factory Pattern.fromJson(Map<String, dynamic> json) {
    return Pattern(
      name: json['name'] ?? 'CustomPattern',
      walls: (json['walls'] as List? ?? [])
          .map((w) => Wall.fromJson(w))
          .toList(),
    );
  }
}

class Phase {
  final String name;
  final double duration;
  final double rotationSpeed; // Z rotation speed (radians/s)
  final int direction;        // 1 = CCW, -1 = CW
  final double tiltSpeedX;    // X tilt speed (radians/s) — creates 3D perspective
  final double tiltSpeedY;    // Y tilt speed (radians/s)
  final List<Pattern> patterns;

  Phase({
    required this.name,
    required this.duration,
    this.rotationSpeed = 1.0,
    this.direction = 1,
    this.tiltSpeedX = 0.0,
    this.tiltSpeedY = 0.0,
    required this.patterns,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'duration': duration,
        'rotationSpeed': rotationSpeed,
        'direction': direction,
        'tiltSpeedX': tiltSpeedX,
        'tiltSpeedY': tiltSpeedY,
        'patterns': patterns.map((p) => p.toJson()).toList(),
      };

  factory Phase.fromJson(Map<String, dynamic> json) {
    return Phase(
      name: json['name'] ?? 'Phase',
      duration: (json['duration'] ?? 10.0).toDouble(),
      rotationSpeed: (json['rotationSpeed'] ?? 1.0).toDouble(),
      direction: json['direction'] ?? 1,
      tiltSpeedX: (json['tiltSpeedX'] ?? 0.0).toDouble(),
      tiltSpeedY: (json['tiltSpeedY'] ?? 0.0).toDouble(),
      patterns: (json['patterns'] as List? ?? [])
          .map((p) => Pattern.fromJson(p))
          .toList(),
    );
  }
}

class Level {
  final List<Phase> phases;

  Level({
    required this.phases,
  });

  Map<String, dynamic> toJson() => {
        'phases': phases.map((p) => p.toJson()).toList(),
      };

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      phases: (json['phases'] as List? ?? [])
          .map((p) => Phase.fromJson(p))
          .toList(),
    );
  }
}

// --- Level Metadata Structure ---

class LevelMetadata {
  final String id;
  final String title;
  final String difficulty;
  final String song;
  final int sides;
  final double baseRotationSpeed;
  final Level level; // Loaded level script
  final List<Vector4> colorPalette; // Background segment colors

  LevelMetadata({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.song,
    required this.sides,
    this.baseRotationSpeed = 1.0,
    required this.level,
    required this.colorPalette,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'difficulty': difficulty,
        'song': song,
        'sides': sides,
        'baseRotationSpeed': baseRotationSpeed,
        'level': level.toJson(),
        // Excluded colorPalette from serialization to keep storage compact
      };
}

class LevelDump {
  static Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/level_dump.json');
  }

  /// Loads all user metadata progress map from local disk.
  static Future<Map<String, UserMetadata>> loadAllProgress() async {
    try {
      final file = await _file;
      if (!await file.exists()) {
        return {};
      }
      final contents = await file.readAsString();
      final Map<String, dynamic> rawJson = jsonDecode(contents);
      return rawJson.map(
        (key, value) => MapEntry(key, UserMetadata.fromJson(value)),
      );
    } catch (e) {
      PlxLogger.error('LevelDump error loading progress: $e', system: 'LevelDump');
      return {};
    }
  }

  /// Saves the complete progress map back to local disk.
  static Future<void> saveProgress(Map<String, UserMetadata> allProgress) async {
    try {
      final file = await _file;
      final rawMap = allProgress.map((key, value) => MapEntry(key, value.toJson()));
      await file.writeAsString(jsonEncode(rawMap));
    } catch (e) {
      PlxLogger.error('LevelDump error saving progress: $e', system: 'LevelDump');
    }
  }

  /// Gets the specific UserMetadata for a level ID and user ID.
  static Future<UserMetadata> getProgress(String levelId, String userId) async {
    final all = await loadAllProgress();
    final key = '${userId}_$levelId';
    if (all.containsKey(key)) {
      return all[key]!;
    }
    return UserMetadata(
      session: Session(userId: userId, scores: {}),
      levelId: levelId,
      bestScore: 0,
      bestTime: 0.0,
    );
  }

  /// Updates score and survival time, maintaining high scores.
  static Future<UserMetadata> updateProgress({
    required String levelId,
    required String userId,
    required int score,
    required double time,
  }) async {
    final all = await loadAllProgress();
    final key = '${userId}_$levelId';
    final existing = all[key];

    int newBestScore = score;
    double newBestTime = time;
    Map<String, int> scores = {};

    if (existing != null) {
      newBestScore = max(existing.bestScore, score);
      newBestTime = max(existing.bestTime, time);
      scores = Map<String, int>.from(existing.session.scores);
    }

    scores[levelId] = newBestScore;

    final updated = UserMetadata(
      session: Session(userId: userId, scores: scores),
      levelId: levelId,
      bestScore: newBestScore,
      bestTime: newBestTime,
    );

    all[key] = updated;
    await saveProgress(all);
    return updated;
  }
}

class LevelTemplates {
  /// Generates the standard 3 levels
  static List<LevelMetadata> getBuiltInLevels() {
    return [
      getHexagonFlightLevel(),
      getVortexRunnerLevel(),
      getExagonPlusLevel(),
    ];
  }
}
