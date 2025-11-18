import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BannerHorizontal extends NineTileBoxComponent with HasGameReference<FlameGame> {
  final String? text;
  final double fontSize;
  final Color textColor;

  BannerHorizontal({
    required Vector2 position,
    required Vector2 size,
    this.text,
    this.fontSize = 24.0,
    this.textColor = Colors.white,
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

    // Add text component if provided
    if (text != null) {
      final textComponent = TextComponent(
        text: text!,
        textRenderer: TextPaint(
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: size / 2, // Center of the banner
      );
      add(textComponent);
    }
  }
}

