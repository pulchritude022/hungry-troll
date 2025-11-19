import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/troll.dart';
import '../components/button.dart';
import '../components/banner_horizontal.dart';
import '../components/tiled_background.dart';
import '../components/tree.dart';
import '../state/game_state.dart';
import '../services/upgrade_service.dart';
import '../components/sheep_spawn_button.dart';
import '../components/upgrade_button.dart';
import '../data/upgrades_data.dart';
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
    return GameWidget(game: game);
  }
}

class HungryTrollGame extends FlameGame with TapCallbacks {
  final GameState gameState;
  late final UpgradeService upgradeService;
  late Troll troll;
  late Button spawnButton;
  late BannerHorizontal resourceBanner;
  final Random random = Random();
  
  HungryTrollGame({GameState? gameState}) : gameState = gameState ?? GameState() {
    upgradeService = UpgradeService(this.gameState, this.gameState.upgradeState);
  }
  
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Add tiled background first (renders behind everything)
    final background = TiledBackground(
      imagePath: 'free_pack/terrain/tilemap_color1.png',
      tileSourcePosition: Vector2(64, 64), // Second row, second column (0-indexed)
      tileSize: Vector2(64, 64),
    );
    add(background);

    // Spawn trees around the edges
    _spawnTreesAroundEdges();

    final frameSize = Vector2(384, 384);
    const imageScale = 1.0;

    troll = Troll(position: size / 2, size: frameSize * imageScale);
    add(troll);

    resourceBanner = BannerHorizontal(
      position: Vector2(size.x / 2, 64),
      size: Vector2(250, 160),
    );
    resourceBanner.gameState = gameState;
    add(resourceBanner);

    final sheepSpawnButton = SheepSpawnButton(
      position: Vector2(size.x / 2, size.y - 100),
    );
    add(sheepSpawnButton);

    // Upgrade Buttons
    final sheepMaxUpgradeButton = UpgradeButton(
      upgradeId: Upgrades.maxSheepCount,
      position: Vector2(size.x-70, size.y-70),
    );
    add(sheepMaxUpgradeButton);

    final sheepPerClickUpgradeButton = UpgradeButton(
      upgradeId: Upgrades.sheepPerSpawn,
      position: Vector2(size.x-70, size.y-190),
    );
    add(sheepPerClickUpgradeButton);

    final meatPerSheepUpgradeButton = UpgradeButton(
      upgradeId: Upgrades.meatDropAmount,
      position: Vector2(size.x-70, size.y-310),
    );
    add(meatPerSheepUpgradeButton);
  }

  Vector2 generateRandomPosition() {
    const minDistance = 200.0;
    const topMargin = 150.0;
    const bottomMargin = 250.0;
    const sideMargin = 120.0;
    
    Vector2 position;
    int attempts = 0;
    const maxAttempts = 100;
    
    do {
      position = Vector2(
        sideMargin + random.nextDouble() * (size.x - 2 * sideMargin),
        topMargin + random.nextDouble() * (size.y - topMargin - bottomMargin),
      );
      attempts++;
    } while (
      position.distanceTo(troll.position) < minDistance &&
      attempts < maxAttempts
    );
    
    return position;
  }

  void _spawnTreesAroundEdges() {
    const edgeMargin = 64.0; // Trees spawn within 64 pixels of the edge
    const treeCount = 50; // Total number of trees to spawn
    
    final treeTypes = [TreeType.tree1, TreeType.tree2, TreeType.tree3, TreeType.tree4];
    
    for (int i = 0; i < treeCount; i++) {
      // Randomly choose which edge: 0=top, 1=right, 2=bottom, 3=left
      final edge = random.nextInt(3); // Ignore the bottom for now
      Vector2 position;
      
      switch (edge) {
        case 0: // Top edge
          position = Vector2(
            random.nextDouble() * size.x,
            random.nextDouble() * edgeMargin + edgeMargin, // Shift the top down by more than the edge margin
          );
          break;
        case 1: // Right edge
          position = Vector2(
            size.x - random.nextDouble() * edgeMargin,
            random.nextDouble() * size.y,
          );
          break;
        case 2: // Left edge
          position = Vector2(
            random.nextDouble() * edgeMargin,
            random.nextDouble() * size.y,
          );
          break;
        case 3: // Bottom edge
        default:
          position = Vector2(
            random.nextDouble() * size.x,
            size.y - random.nextDouble() * edgeMargin,
          );
          break;
      }
      
      // Randomly select a tree type
      final treeType = treeTypes[random.nextInt(treeTypes.length)];
      
      // Create and add the tree
      final tree = Tree(
        position: position,
        treeType: treeType,
      );
      add(tree);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    troll.moveTo(event.localPosition);
  }
}
