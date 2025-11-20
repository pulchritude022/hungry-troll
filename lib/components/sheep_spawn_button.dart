import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'button.dart';
import 'sheep.dart';


class SheepSpawnButton extends Button {
  late TextComponent sheepCount;

  SheepSpawnButton({
    required super.position,
  }) : super(
    buttonType: ButtonType.blue,
    size: Vector2(120, 120),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final imageIdle = await game.images.load('free_pack/decorations/sheep/sheep_idle.png');
    final textureSize = Vector2(128, 128);
    final sheepAnimation = SpriteAnimation.fromFrameData(imageIdle, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/15, textureSize: textureSize, loop: true));
    
    final animationComponent = SpriteAnimationComponent(
      animation: sheepAnimation,
      anchor: Anchor.center,
      position: Vector2(size.x/2, size.y/2 - 20),
      size: textureSize * 0.75,
    );
    add(animationComponent);

    sheepCount = TextComponent(
      text: 'Sheep: ${game.gameState.sheepCount}',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'BearDays',
        ),
      ),
      position: Vector2(size.x/2, size.y/2 + 20),
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
    
    final spawnCount = game.gameState.sheepPerSpawn;

    int spawned = 0;
    for (int i = 0; i < spawnCount; i++) {
      if (game.gameState.canSpawnSheep()) {
        final position = game.generateRandomPosition();
        final sheep = Sheep(position: position, size: Vector2(128, 128));
        sheep.troll = game.troll;
        sheep.gameState = game.gameState;
        game.gameState.incrementSheep();
        game.add(sheep);
        spawned++;
      } else {
        break; // Stop if we hit the limit
      }
    }
    
    if (spawned > 0) {
      print('Button pressed! Spawned $spawned sheep.');
    } else {
      print('Cannot spawn sheep!');
    }
  }

  void _updateDisplay() {
    sheepCount.text = '${game.gameState.sheepCount}/${game.gameState.sheepMaxCount}';
    if (game.gameState.canSpawnSheep()) {
      enable();
    } else {
      disable();
    }
  }
}
