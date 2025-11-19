import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../state/game_state.dart';
import 'resource_display.dart';

class BannerHorizontal extends NineTileBoxComponent with HasGameReference<FlameGame> {
  GameState? gameState;
  ResourceDisplay? _resourceDisplay;

  BannerHorizontal({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 10000;

    // Load the banner sprite
    final sprite = await Sprite.load('UI/Banners/Banner_Horizontal.png');

    // The source image is 192x192, divided into a 3x3 grid
    // Each tile is 64x64 (192 / 3 = 64)
    const sourceTileSize = 64;

    // Create NineTileBox instance for the banner
    nineTileBox = NineTileBox(
      sprite,
      tileSize: sourceTileSize,
    );

    // Create resource display for meat
    _resourceDisplay = ResourceDisplay(
      iconPath: 'Resources/Resources/M_Idle.png',
      initialCount: 0,
      position: size / 2,
    );
    add(_resourceDisplay!);
    
    // Listen to game state changes
    gameState?.addListener(_updateDisplay);
  }

  void _updateDisplay() {
    if (_resourceDisplay != null && gameState != null) {
      _resourceDisplay!.updateCount(gameState!.meat);
    }
  }

  @override
  void onRemove() {
    gameState?.removeListener(_updateDisplay);
    super.onRemove();
  }
}

