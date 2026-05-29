import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exa_vortex/app/scenes/background_scene.dart';
import 'package:exa_vortex/app/entities/background.dart';
import 'package:exa_vortex/app/entities/center.dart';
import 'package:exa_vortex/app/entities/player.dart';
import 'package:exa_vortex/app/entities/wall.dart';
import 'package:exa_vortex/app/components/rotator.dart';
import 'package:exa_vortex/app/utils/level_metadata.dart' hide Wall;
import 'package:exa_vortex/app/utils/level_vm.dart';
import 'package:exa_vortex/app/ui/level_selector_ui.dart';
import 'package:exa_vortex/app/ui/gameplay_hud.dart';
import 'package:exa_vortex/app/ui/game_over_ui.dart';
import 'package:exa_vortex/plx/plx.dart' hide Colors;
import 'package:exa_vortex/plx/plx3d.dart';

enum GameplayState {
  selecting,
  playing,
  gameover,
}

class GameplayScene extends GameScene {
  // State
  GameplayState state = GameplayState.selecting;
  List<LevelMetadata> levels = [];
  int selectedLevelIndex = 0;
  
  // Local Stats for selected level
  int bestScore = 0;
  double bestTime = 0.0;
  bool isNewRecord = false;
  
  // Gameplay variables
  double survivalTime = 0.0;
  int currentScore = 0;
  double playerAngle = 0.0; // In radians
  double rotationSpeed = 4.5; // Radians per second
  
  // Resources
  late AudioHandler audioHandler;
  late PlxMaterial material;
  late MeshRenderer meshRenderer;

  // Level Timeline VM
  LevelVM? levelVM;

  // Entities
  late World world;
  late Camera3D camera;
  late Background background;
  late CenterShape center;
  late ArrowPlayer player;

  // Physics wall pool — reused across frames, grown on demand, never shrunk
  final List<WallShape> _wallPool = [];

  // Touch navigation controls (dynamic state updated by gesture overlay)
  bool isPressingLeft = false;
  bool isPressingRight = false;

  @override
  Future<void> onLoad() async {
    levels = LevelTemplates.getBuiltInLevels();
    audioHandler = AudioHandler();
    // Preload every unique song from level metadata.
    // All currently map to the same placeholder file — swap the asset later.
    final Set<String> loaded = {};
    for (final lvl in levels) {
      if (loaded.add(lvl.song)) {
        await audioHandler.preload(lvl.song, '.assets/audio/shape_whirlwinds.ogg');
      }
    }

    // Load existing high scores for the first level
    await _loadStatsForSelectedLevel();

    return super.onLoad();
  }

  @override
  void onInit() {
    super.onInit();
    
    final currentLevel = levels[selectedLevelIndex];

    // Build the solid material for custom geometry
    material = PlxGraphics.instance.createMaterial(
      vertexShaderName: 'BaseTextureV',
      fragmentShaderName: 'BaseTextureF',
    );
    material.setTexture(
      PlxShader.fragment,
      'tex',
      PlxGraphics.instance.createTextureFromPixels(1, 1, [0xFFFFFFFF]),
    );
    meshRenderer = MeshRenderer(material: material);

    // Construct World & Entities
    world = World();
    
    background = Background(
      name: 'GameplayBG',
      numSides: 6,
      radius: 1000,
    );
    background.setColorPalette(currentLevel.colorPalette);
    background.addComponent(MeshRenderer(material: material));
    background.addComponent(Rotator.fromSpeed(
      speed: Vector3(0, 0, currentLevel.baseRotationSpeed),
    ));

    final obstacleColor = currentLevel.colorPalette.length > 2
        ? currentLevel.colorPalette[2]
        : Vector4(1, 1, 1, 1);

    player = ArrowPlayer(color: obstacleColor);
    player.addComponent(MeshRenderer(material: material));
    background.addChild(player);

    center = CenterShape(
      sides: currentLevel.sides,
      fillColor: currentLevel.colorPalette.first,
      borderColor: obstacleColor,
    );
    center.addComponent(MeshRenderer(material: material));
    background.addChild(center);

    camera = Camera3D(name: 'Camera', world: world);
    camera.position = Vector3(0, 0, 5);
    camera.view?.far = 1000;

    world.addChild(background);
    addEntity(camera);
    addEntity(world);

    // Setup input bindings for Keyboard
    input.enableKeyboard();
    input.clearBindings();
    
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowLeft), 'Left');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.keyA), 'Left');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.arrowRight), 'Right');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.keyD), 'Right');
    
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.escape), 'Exit');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.space), 'Action');
    input.bindInput(PhysicalInput.keyboard(LogicalKeyboardKey.enter), 'Action');

    // Initial visual update
    _regenerateGameplayMesh();
  }

  Future<void> _loadStatsForSelectedLevel() async {
    final level = levels[selectedLevelIndex];
    final progress = await LevelDump.getProgress(level.id, 'PabloXantini');
    bestScore = progress.bestScore;
    bestTime = progress.bestTime;
    refreshUI();
  }

  void _switchLevel(int direction) {
    if (state != GameplayState.selecting) return;
    
    selectedLevelIndex = (selectedLevelIndex + direction) % levels.length;
    if (selectedLevelIndex < 0) selectedLevelIndex += levels.length;
    
    final currentLevel = levels[selectedLevelIndex];
    
    // Dynamically change background color palette and visual colors immediately
    background.setColorPalette(currentLevel.colorPalette);
    
    final obstacleColor = currentLevel.colorPalette.length > 2
        ? currentLevel.colorPalette[2]
        : Vector4(1, 1, 1, 1);
    // Update center entity for new level
    center = CenterShape(
      sides: currentLevel.sides,
      fillColor: currentLevel.colorPalette.first,
      borderColor: obstacleColor,
    );
    center.addComponent(MeshRenderer(material: material));
    background.children.removeWhere((e) => e is CenterShape);
    background.addChild(center);
    
    background.getComponent<Rotator>()?.speed = Vector3(0, 0, currentLevel.baseRotationSpeed);
    background.rotation.x = 0;
    background.rotation.y = 0;
    background.rotation.z = 0;
    
    player.syncCollider(playerAngle, playerColor: obstacleColor);
    
    _loadStatsForSelectedLevel();
    _regenerateGameplayMesh();
  }

  void _startGame() {
    if (state == GameplayState.playing) return;

    state = GameplayState.playing;
    survivalTime = 0.0;
    currentScore = 0;
    playerAngle = 0.0;
    isNewRecord = false;
    isPressingLeft = false;
    isPressingRight = false;

    // Clear wall pool so stale colliders don't linger between runs
    for (var w in _wallPool) {
      w.getComponent<MeshRenderer>()?.dispose();
    }
    _wallPool.clear();
    background.children.removeWhere((e) => e is WallShape);

    // Reset level timeline VM
    final currentLevel = levels[selectedLevelIndex];
    levelVM = LevelVM(level: currentLevel.level);
    levelVM!.reset();

    // Reset background rotation and update speed from level
    background.getComponent<Rotator>()?.speed = Vector3(0, 0, currentLevel.baseRotationSpeed);
    background.rotation.x = 0;
    background.rotation.y = 0;
    background.rotation.z = 0;
    
    audioHandler.playSoundtrack(currentLevel.song, volume: 1);

    refreshUI();
  }

  void _triggerGameOver() {
    if (state != GameplayState.playing) return;

    state = GameplayState.gameover;
    audioHandler.pauseSoundtrack();

    // Save final stats and check for record
    final currentLevel = levels[selectedLevelIndex];
    
    // Check if new record
    if (currentScore > bestScore || survivalTime > bestTime) {
      isNewRecord = true;
    }

    LevelDump.updateProgress(
      levelId: currentLevel.id,
      userId: 'PabloXantini',
      score: currentScore,
      time: survivalTime,
    ).then((_) {
      _loadStatsForSelectedLevel();
    });

    refreshUI();
  }

  void _regenerateGameplayMesh() {
    // Meshes are now generated per-entity in PlayerEntity and WallEntity.
    // We only need to sync the active walls with the pool here.
    if (levelVM == null) return;
    
    final currentLevel = levels[selectedLevelIndex];
    final activeWalls = levelVM!.activeWalls;
    
    final obstacleColor = currentLevel.colorPalette.length > 2 
        ? currentLevel.colorPalette[2] 
        : Vector4(1, 1, 1, 1);

    // Grow the wall pool on demand
    while (_wallPool.length < activeWalls.length) {
      final w = WallShape();
      w.addComponent(MeshRenderer(material: material));
      _wallPool.add(w);
      background.addChild(w);
    }

    // Sync each pooled wall to the matching active wall and manage visibility
    for (int i = 0; i < _wallPool.length; i++) {
      if (i < activeWalls.length) {
        _wallPool[i].active = true;
        _wallPool[i].syncFromActiveWall(
          activeWalls[i], 
          numSides: currentLevel.sides, 
          color: obstacleColor,
        );
      } else {
        _wallPool[i].active = false;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // dizzying spinning camera effect!
    if (state == GameplayState.playing) {
      camera.rotation.z += 0.25 * dt;
    } else {
      camera.rotation.z += 0.08 * dt; // slow rotation on menu screen
    }

    // Keyboard global navigation escape
    if (input.isActionTriggered('Exit')) {
      if (state == GameplayState.playing) {
        _triggerGameOver();
      } else if (state == GameplayState.selecting) {
        requestSceneChange(BackgroundScene());
      } else if (state == GameplayState.gameover) {
        state = GameplayState.selecting;
        refreshUI();
      }
    }

    switch (state) {
      case GameplayState.selecting:
        if (input.isActionTriggered('Action')) {
          _startGame();
        }
        break;
      case GameplayState.playing:
        // Update gameplay metrics
        survivalTime += dt;
        // 10 score points per survived second
        currentScore = (survivalTime * 10).floor();

        // 1. Rotate Player Cursor
        if (input.isActionTriggered('Left') || isPressingLeft) {
          playerAngle += rotationSpeed * dt;
        }
        if (input.isActionTriggered('Right') || isPressingRight) {
          playerAngle -= rotationSpeed * dt;
        }

        // 2. Run Level Timeline script VM
        levelVM?.update(dt, startDistance: 6.0, minDistance: 0.3);

        // Update Rotator speed/direction from VM phase
        if (levelVM != null) {
          final phase = levelVM!.currentPhase;
          final rotator = background.getComponent<Rotator>();
          if (rotator != null && phase != null) {
            rotator.speed = Vector3(
              phase.tiltSpeedX,
              phase.tiltSpeedY,
              phase.rotationSpeed * phase.direction,
            );
          }
        }

        // 3. Update the combined dynamic meshes (also syncs wall pool size)
        _regenerateGameplayMesh();

        // 4. Collision Evaluation
        _checkCollisions();
        break;
      case GameplayState.gameover:
        if (input.isActionTriggered('Action')) {
          _startGame();
        }
        break;
    }
  }

  void _checkCollisions() {
    if (levelVM == null) return;

    final activeWalls = levelVM!.activeWalls;

    final currentLevel = levels[selectedLevelIndex];
    final obstacleColor = currentLevel.colorPalette.length > 2 
        ? currentLevel.colorPalette[2] 
        : Vector4(1, 1, 1, 1);

    // syncCollider updates both the physics collider position AND regenerates the mesh,
    // so the player visually tracks the input angle every frame.
    player.syncCollider(playerAngle, playerColor: obstacleColor);

    // SAT narrow-phase: player vs every active wall (both in background-local space)
    for (int i = 0; i < activeWalls.length; i++) {
      final manifold = SATSolver.test(
        player.collider,
        _wallPool[i].collider,
      );

      if (manifold != null) {
        _triggerGameOver();
        return;
      }
    }
  }

  @override
  List<Widget> buildUI(BuildContext context) {
    switch (state) {
      case GameplayState.selecting:
        return [
          LevelSelectorUI(
            levels: levels,
            selectedIndex: selectedLevelIndex,
            bestScore: bestScore,
            bestTime: bestTime,
            onPrev: () => _switchLevel(-1),
            onNext: () => _switchLevel(1),
            onStart: _startGame,
            onBack: () => requestSceneChange(BackgroundScene()),
          ),
        ];
      case GameplayState.playing:
        return [
          // Gesture Touch Overlay for rotation (left half = counter-clockwise, right half = clockwise)
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < screenWidth / 2) {
                  isPressingLeft = true;
                  isPressingRight = false;
                } else {
                  isPressingRight = true;
                  isPressingLeft = false;
                }
              },
              onTapUp: (_) {
                isPressingLeft = false;
                isPressingRight = false;
              },
              onTapCancel: () {
                isPressingLeft = false;
                isPressingRight = false;
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          GameplayHUD(
            survivalTime: survivalTime,
            currentScore: currentScore,
            phaseName: levelVM?.currentPhaseName ?? 'Phase 1',
          ),
        ];
      case GameplayState.gameover:
        return [
          GameOverUI(
            survivalTime: survivalTime,
            score: currentScore,
            isNewRecord: isNewRecord,
            onRetry: _startGame,
            onExit: () {
              state = GameplayState.selecting;
              _loadStatsForSelectedLevel();
            },
          ),
        ];
    }
  }

  @override
  void draw(PlxRenderer renderer) {
    // Dynamic background base coloring
    final cb = background.colorPalette.first;
    renderer.setBackgroundColor(Vector4(cb.x, cb.y, cb.z, cb.w));
    
    world.draw(renderer);
    super.draw(renderer);
  }

  @override
  void dispose() {
    audioHandler.dispose();
    material.dispose();
    meshRenderer.dispose();
    super.dispose();
  }
}