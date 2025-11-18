import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ResourceDisplay extends PositionComponent {
  final String iconPath;
  final int initialCount;
  late TextComponent _countText;
  late SpriteComponent _iconSprite;

  ResourceDisplay({
    required this.iconPath,
    required this.initialCount,
    super.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load and add sprite (icon on the right)
    final sprite = await Sprite.load(iconPath);
    _iconSprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(96, 96),
      position: Vector2(5, 0),  // Small gap from text
      anchor: Anchor(.25, 80/128),  // Left edge at x=5, centered vertically
    );
    add(_iconSprite);

    // Create text component (number on the left)
    _countText = TextComponent(
      text: '$initialCount',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.deepOrangeAccent,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'BearDays',
        ),
      ),
      position: Vector2(0, 0),
      anchor: Anchor.centerRight,  // Right edge at x=0, centered vertically
    );
    add(_countText);
  }

  void updateCount(int newCount) {
    _countText.text = '$newCount';
  }
}

