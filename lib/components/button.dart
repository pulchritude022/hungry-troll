import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import '../game/hungry_troll_game.dart';

enum ButtonState { normal, pressed }
enum ButtonType { blue, red }

class Button extends NineTileBoxComponent
    with TapCallbacks, HasGameReference<HungryTrollGame> {
  final ButtonType buttonType;
  late NineTileBox _nineTileBoxNormal;
  late NineTileBox _nineTileBoxPressed;
  late NineTileBox _nineTileBoxDisabled;
  bool isDisabled = false;

  Button({
    required Vector2 position,
    required Vector2 size,
    this.buttonType = ButtonType.blue,
    this.isDisabled = false,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    priority = 10000;

    Sprite? spriteNormal;
    Sprite? spritePressed;

    switch (buttonType) {
      case ButtonType.blue:
        spriteNormal = await Sprite.load('ui/buttons/button_blue_9slides.png');
        spritePressed = await Sprite.load('ui/buttons/button_blue_9slides_pressed.png');
        break;
      case ButtonType.red:
        spriteNormal = await Sprite.load('ui/buttons/button_red_9slides.png');
        spritePressed = await Sprite.load('ui/buttons/button_red_9slides_pressed.png');
        break;
    }

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

    final spriteDisabled = await Sprite.load('ui/buttons/button_disable_9slides.png');

    _nineTileBoxDisabled = NineTileBox(
      spriteDisabled,
      tileSize: sourceTileSize,
    );

    // Set the initial state
    if (isDisabled) {
      nineTileBox = _nineTileBoxDisabled;
    } else {
      nineTileBox = _nineTileBoxNormal;
    }
  }

  void disable() {
    isDisabled = true;
    nineTileBox = _nineTileBoxDisabled;
  }

  void enable() {
    isDisabled = false;
    nineTileBox = _nineTileBoxNormal;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (isDisabled) return;
    nineTileBox = _nineTileBoxPressed;
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (isDisabled) return;
    nineTileBox = _nineTileBoxNormal;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    super.onTapCancel(event);
    nineTileBox = _nineTileBoxNormal;
  }
}

