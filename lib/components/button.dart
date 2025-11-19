import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

enum ButtonState { normal, pressed }

class Button extends NineTileBoxComponent
    with TapCallbacks, HasGameReference<FlameGame> {
  final VoidCallback? onPressed;
  final SpriteAnimation? animation;
  
  late NineTileBox _nineTileBoxNormal;
  late NineTileBox _nineTileBoxPressed;

  Button({
    required Vector2 position,
    required Vector2 size,
    this.onPressed,
    this.animation,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load both button sprites
    final spriteNormal = await Sprite.load('UI/Buttons/Button_Blue_9Slides.png',);
    final spritePressed = await Sprite.load('UI/Buttons/Button_Blue_9Slides_Pressed.png',);

    // The source image is 192x192, divided into a 3x3 grid
    // Each tile is 64x64 (192 / 3 = 64)
    const sourceTileSize = 64;

    // Create NineTileBox instances for both button states
    _nineTileBoxNormal = NineTileBox(
      spriteNormal,
      tileSize: sourceTileSize,
    );

    _nineTileBoxPressed = NineTileBox(
      spritePressed,
      tileSize: sourceTileSize,
    );

    // Set the initial state
    nineTileBox = _nineTileBoxNormal;

    // Add animation component if provided
    if (animation != null) {
      final animationComponent = SpriteAnimationComponent(
        animation: animation,
        anchor: Anchor.center,
        position: size / 2, // Center of the button
      );
      add(animationComponent);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    nineTileBox = _nineTileBoxPressed;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    nineTileBox = _nineTileBoxNormal;
    onPressed?.call();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    nineTileBox = _nineTileBoxNormal;
  }
}

