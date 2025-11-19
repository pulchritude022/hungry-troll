import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class TiledBackground extends Component with HasGameReference<FlameGame> {
  late Sprite tileSprite;
  final String imagePath;
  final Vector2 tileSourcePosition;
  final Vector2 tileSize;

  TiledBackground({
    required this.imagePath,
    required this.tileSourcePosition,
    required this.tileSize,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load the tilemap image
    final image = await game.images.load(imagePath);
    
    // Extract the specific tile from the tilemap
    tileSprite = Sprite(
      image,
      srcPosition: tileSourcePosition,
      srcSize: tileSize,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Calculate how many tiles we need to fill the screen
    final tilesX = (game.size.x / tileSize.x).ceil();
    final tilesY = (game.size.y / tileSize.y).ceil();
    
    // Render tiles in a grid pattern
    for (int y = 0; y < tilesY; y++) {
      for (int x = 0; x < tilesX; x++) {
        final position = Vector2(
          x * tileSize.x,
          y * tileSize.y,
        );
        
        tileSprite.render(
          canvas,
          position: position,
          size: tileSize,
        );
      }
    }
  }

  @override
  int get priority => -1000; // Render behind everything else
}

