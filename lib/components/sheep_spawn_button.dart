import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'button.dart';
import 'sheep.dart';


class SheepSpawnButton extends Button {
  late TextComponent sheepCount;

  SheepSpawnButton({
    required super.position,
    required super.size,
  }) : super(
    buttonType: ButtonType.blue,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final imageIdle = await game.images.load('free_pack/decorations/sheep/sheep_idle.png');
    final sheepAnimation = SpriteAnimation.fromFrameData(imageIdle, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/15, textureSize: Vector2(128, 128), loop: true));
    
    final animationComponent = SpriteAnimationComponent(
      animation: sheepAnimation,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(animationComponent);

    sheepCount = TextComponent(
      text: 'Sheep: ${game.gameState.sheepCount}',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontFamily: 'BearDays',
        ),
      ),
      position: Vector2(size.x/2, size.y/2 + 50),
      anchor: Anchor.center,
    );
    add(sheepCount);  
    
    // Listen to game state changes
    _updateDisplay();
    game.gameState.addListener(_updateDisplay);
  }  

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (game.gameState.canSpawnSheep()) {
      final position = game.generateRandomPosition();
      final sheep = Sheep(position: position, size: Vector2(128, 128));
      sheep.troll = game.troll;
      sheep.gameState = game.gameState;
      game.gameState.incrementSheep();
      game.add(sheep);
      print('Button pressed!');
    } else {
      print('Cannot spawn sheep!');
    }
  }

  void _updateDisplay() {
    sheepCount.text = '${game.gameState.sheepCount} / ${game.gameState.sheepMaxCount}';
    if (game.gameState.canSpawnSheep()) {
      enable();
    } else {
      disable();
    }
  }
}