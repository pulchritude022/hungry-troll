import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../game/hungry_troll_game.dart';

class TiledBackground extends Component with HasGameReference<FlameGame> {
  final String imagePath;
  final Vector2 tileSourcePosition;
  final Vector2 tileSize;
  
  // Pre-rendered background image (no seams since it's a single texture)
  ui.Image? _bakedBackground;

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
    
    // Pre-render all tiles into a single image to eliminate seams
    _bakedBackground = await _bakeBackground(image);
  }

  /// Pre-renders the entire tiled background into a single image.
  /// This eliminates tile seams because the result is one continuous texture.
  Future<ui.Image> _bakeBackground(ui.Image tileSheet) async {
    final int width = worldWidth.toInt();
    final int height = worldHeight.toInt();
    
    // Create a picture recorder to draw tiles onto
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    
    // Source rectangle from the tile sheet
    final srcRect = ui.Rect.fromLTWH(
      tileSourcePosition.x,
      tileSourcePosition.y,
      tileSize.x,
      tileSize.y,
    );
    
    // Calculate how many tiles we need
    final tilesX = (worldWidth / tileSize.x).ceil();
    final tilesY = (worldHeight / tileSize.y).ceil();
    
    // Draw all tiles to the canvas
    for (int y = 0; y < tilesY; y++) {
      for (int x = 0; x < tilesX; x++) {
        final dstRect = ui.Rect.fromLTWH(
          x * tileSize.x,
          y * tileSize.y,
          tileSize.x,
          tileSize.y,
        );
        canvas.drawImageRect(tileSheet, srcRect, dstRect, ui.Paint());
      }
    }
    
    // Convert the recorded picture to an image
    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  @override
  void render(ui.Canvas canvas) {
    super.render(canvas);
    
    if (_bakedBackground != null) {
      // Draw the pre-rendered background as a single image - no seams!
      canvas.drawImage(_bakedBackground!, ui.Offset.zero, ui.Paint());
    }
  }

  @override
  int get priority => -1000; // Render behind everything else
}

