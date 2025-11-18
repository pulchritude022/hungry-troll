import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BannerHorizontal extends NineTileBoxComponent with HasGameReference<FlameGame> {
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

    // Load the banner sprite
    final sprite = await Sprite.load('ui/banners/banner_horizontal.png');

    // The source image is 192x192, divided into a 3x3 grid
    // Each tile is 64x64 (192 / 3 = 64)
    const sourceTileSize = 64;

    // Create NineTileBox instance for the banner
    nineTileBox = NineTileBox(
      sprite,
      tileSize: sourceTileSize,
    );
  }
}

