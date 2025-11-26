import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import '../components/troll.dart';
import '../components/tiled_background.dart';
import '../components/tree.dart';
import '../state/game_state.dart';
import '../services/upgrade_service.dart';
import '../data/upgrades_data.dart';
import '../components/performance_display.dart';
import '../widgets/game_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  late HungryTrollGame game;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    game = HungryTrollGame(gameState: gameState);
  }

  @override
  void dispose() {
    gameState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GameWidget(game: game),
        GameOverlay(game: game, gameState: gameState),
      ],
    );
  }
}

class HungryTrollGame extends FlameGame with TapCallbacks {
  final GameState gameState;
  late final UpgradeService upgradeService;
  late Troll troll;
  late PerformanceDisplay performanceDisplay;
  final Random random = Random();
  
  HungryTrollGame({GameState? gameState}) : gameState = gameState ?? GameState() {
    upgradeService = UpgradeService(this.gameState, this.gameState.upgradeState);
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Debug only: Start with a couple upgrades already purchased
    if (kDebugMode) {
      // Don't trigger notifications during build/load
      gameState.upgradeState.setUpgradeLevel(Upgrades.maxSheepCount, 7, notify: false);
      gameState.upgradeState.setUpgradeLevel(Upgrades.sheepPerSpawn, 3, notify: false);
      gameState.upgradeState.setUpgradeLevel(Upgrades.meatDropAmount, 3, notify: false);
    }

    // Add tiled background first (renders behind everything)
    final background = TiledBackground(
      imagePath: 'free_pack/terrain/tilemap_color1.png',
      tileSourcePosition: Vector2(64, 64), // Second row, second column (0-indexed)
      tileSize: Vector2(64, 64),
    );
    add(background);

    // Spawn trees
    _spawnTrees();

    final frameSize = Vector2(384, 384);
    const imageScale = 1.0;

    troll = Troll(position: size / 2, size: frameSize * imageScale);
    add(troll);

    // UI components are now handled by Flutter Overlay

    performanceDisplay = PerformanceDisplay()..position = Vector2(10, 30);
    if (kDebugMode) {
      // Add performance display
      add(performanceDisplay);
    }
  }

  @override
  void update(double dt) {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      super.update(dt);
      stopwatch.stop();
      performanceDisplay.recordUpdateTime(stopwatch.elapsedMicroseconds);
    } else {
      super.update(dt);
    }
  }

  /// Check if the position is within the spawn circle AND actually on the screen
  bool isWithinSpawnArea(Vector2 position) {
    const horizontalInset = 20.0;
    // Check horizontal clamping
    if (position.x < horizontalInset || position.x > size.x - horizontalInset) {
      return false;
    }
    return isWithinSpawnCircle(position);
  }

  /// Check if the position is within a circle drawn at the center of the screen
  /// Used to exclude trees from spawning in the circle
  bool isWithinSpawnCircle(Vector2 position) {
    final center = Vector2(size.x / 2, size.y / 2);
    final radius = max(0.0, size.y / 2 - 150);

    // Check circle constraint
    return position.distanceTo(center) <= radius;
  }

  Vector2 generateSpawnPosition() {
    Vector2 position;
    const minTrollDistance = 150.0;
    int attempts = 0;
    const maxAttempts = 100;

    do {
      position = Vector2(size.x * random.nextDouble(), size.y * random.nextDouble());
      attempts++;
    } while ((!isWithinSpawnArea(position) || position.distanceTo(troll.position) <= minTrollDistance) && attempts < maxAttempts);

    if (attempts >= 10) {
      print('It took $attempts attempts to generate a valid spawn position');
    }
    
    return position;
  }

  void _spawnTrees() {
    const gridSize = 72.0;
    const variation = 48.0;
    const extraBottomMargin = 150.0;
    final treeTypes = [TreeType.tree1, TreeType.tree2, TreeType.tree3, TreeType.tree4];
    
    for (double x = -gridSize*2; x < size.x + gridSize*2; x += gridSize) {
      for (double y = -gridSize*2; y < size.y + gridSize*2; y += gridSize) {
        final position = Vector2(
          x + random.nextDouble() * variation,
          y + random.nextDouble() * variation,
        );
        
        if (!isWithinSpawnCircle(position) && !isWithinSpawnCircle(position - Vector2(0, extraBottomMargin))) {
          final treeType = treeTypes[random.nextInt(treeTypes.length)];
          final tree = Tree(
            position: position,
            treeType: treeType,
          );
          add(tree);
        }
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    troll.moveTo(event.localPosition);
  }
}
