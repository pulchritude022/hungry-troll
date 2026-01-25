import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame/cache.dart';
import 'package:flame_tiled/flame_tiled.dart';
import '../components/troll.dart';
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

/// Fixed world size for consistent gameplay regardless of screen resolution.
/// The game will be letterboxed/pillarboxed to maintain this aspect ratio.
/// Size matches the island map viewport (20-tile island diameter + padding)
const double worldWidth = 1400.0;
const double worldHeight = 1400.0;

/// The game world that contains all gameplay components.
/// Components added here are rendered in world coordinates (affected by camera).
class GameWorld extends World with HasGameReference<HungryTrollGame> {
  late Troll troll;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Create a custom Images cache with 'tiles/' prefix for tileset images
    // This tells flame_tiled to look for PNG files in assets/tiles/ instead of assets/images/
    final tilesImages = Images(prefix: 'tiles/');
    
    // Load the Tiled map (island with water, cliffs, decorations)
    // Use FilterQuality.none to prevent tile seams (black lines between tiles)
    final tiledMap = await TiledComponent.load(
      'ts_round_island_20x20.tmx',
      Vector2.all(64),
      images: tilesImages,
      layerPaintFactory: (opacity) => Paint()
        ..color = Color.fromRGBO(255, 255, 255, opacity)
        ..filterQuality = FilterQuality.none,
    );
    add(tiledMap);

    final frameSize = Vector2(384, 384);
    const imageScale = 1.0;

    troll = Troll(
      position: Vector2(1920, 1920), // Center of the island in map coordinates
      size: frameSize * imageScale,
    );
    add(troll);
  }

  /// Check if the position is within the circular island spawn area
  /// Island is 20 tiles (1280px) diameter, centered at (1920, 1920) in map coords
  /// Spawn area is ~600px radius from center (slightly smaller than island)
  bool isWithinSpawnArea(Vector2 position) {
    return isWithinSpawnCircle(position);
  }

  /// Check if the position is within the circular island
  /// Center: (1920, 1920) in map coordinates, Island radius: ~640px, Spawn radius: ~600px
  bool isWithinSpawnCircle(Vector2 position) {
    final center = Vector2(1920, 1920); // Center of 60x60 tile map
    const spawnRadius = 600.0;  // Stay within island boundaries

    // Check circle constraint
    return position.distanceTo(center) <= spawnRadius;
  }

  Vector2 generateSpawnPosition() {
    Vector2 position;
    const minTrollDistance = 150.0;
    int attempts = 0;
    const maxAttempts = 100;

    // Generate random position within circular island
    final center = Vector2(1920, 1920); // Center of 60x60 tile map
    const spawnRadius = 600.0;

    do {
      // Generate random angle and distance for circular distribution
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * spawnRadius;
      position = center + Vector2(cos(angle) * distance, sin(angle) * distance);
      attempts++;
    } while ((position.distanceTo(troll.position) <= minTrollDistance) && attempts < maxAttempts);

    if (attempts >= 10) {
      print('It took $attempts attempts to generate a valid spawn position');
    }
    
    return position;
  }
}

class HungryTrollGame extends FlameGame with TapCallbacks {
  final GameState gameState;
  late final UpgradeService upgradeService;
  late final GameWorld gameWorld;
  late PerformanceDisplay performanceDisplay;
  
  /// Convenience accessor for the troll component
  Troll get troll => gameWorld.troll;
  
  HungryTrollGame({GameState? gameState}) 
      : gameState = gameState ?? GameState() {
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

    // Create and set up the game world
    gameWorld = GameWorld();
    camera.world = gameWorld;
    add(gameWorld);

    // Center the camera on the island center
    // Map is 60x60 tiles (3840x3840px), island is centered at (1920, 1920)
    camera.viewfinder.position = Vector2(1920, 1920);
    
    // Set initial zoom to ensure at least 1400 units are visible
    _updateCameraZoom();

    // UI components are now handled by Flutter Overlay
    // PerformanceDisplay is added to camera viewport (HUD layer, not affected by world)
    performanceDisplay = PerformanceDisplay()..position = Vector2(10, 30);
    if (kDebugMode) {
      camera.viewport.add(performanceDisplay);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateCameraZoom();
  }

  /// Adjusts camera zoom so at least 1500x1500 units are visible,
  /// while showing more content on wider/taller screens
  void _updateCameraZoom() {
    // Calculate zoom to ensure minimum 1500 units visible in smallest dimension
    final minVisibleSize = 1500.0;
    
    // Use the smaller screen dimension to calculate zoom
    // This ensures the minimum 1400x1400 area is always visible
    final smallerDimension = size.x < size.y ? size.x : size.y;
    final zoom = smallerDimension / minVisibleSize;
    
    camera.viewfinder.zoom = zoom;
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

  /// Check if the position is within the spawn circle AND actually within world bounds
  bool isWithinSpawnArea(Vector2 position) => gameWorld.isWithinSpawnArea(position);

  /// Check if the position is within a circle drawn at the center of the world
  bool isWithinSpawnCircle(Vector2 position) => gameWorld.isWithinSpawnCircle(position);

  /// Generate a random spawn position within the spawn area
  Vector2 generateSpawnPosition() => gameWorld.generateSpawnPosition();

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Convert viewport coordinates to world coordinates
    final worldPosition = camera.globalToLocal(event.devicePosition);
    troll.moveTo(worldPosition);
  }
}
