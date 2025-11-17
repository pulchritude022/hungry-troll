import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

enum ButtonState { normal, pressed }

class Button extends SpriteGroupComponent<ButtonState>
    with TapCallbacks, HasGameReference<FlameGame> {
  final VoidCallback? onPressed;

  Button({
    required super.position,
    required super.size,
    this.onPressed,
  }) : super(
          current: ButtonState.normal,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load both button sprites
    final imageNormal = await game.images.load('ui/buttons/button_blue.png');
    final imagePressed = await game.images.load('ui/buttons/button_blue_pressed.png');

    sprites = {
      ButtonState.normal: Sprite(imageNormal),
      ButtonState.pressed: Sprite(imagePressed),
    };
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    current = ButtonState.pressed;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    current = ButtonState.normal;
    onPressed?.call();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    current = ButtonState.normal;
  }
}

