import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/troll.dart';
import '../components/sheep.dart';
import '../components/button.dart';
import '../components/banner_horizontal.dart';

class GameScreen extends StatelessWidget {
  final HungryTrollGame game = HungryTrollGame();

  GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
}

class HungryTrollGame extends FlameGame with TapCallbacks {
  late Troll troll;
  late Button spawnButton;
  late BannerHorizontal resourceBanner;
  final Random random = Random();
  
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final frameSize = Vector2(384, 384);
    const imageScale = 1.0;

    troll = Troll(position: size / 2, size: frameSize * imageScale);
    add(troll);

    
    final imageIdle = await images.load('free_pack/decorations/sheep/sheep_idle.png');

    resourceBanner = BannerHorizontal(
      position: Vector2(size.x / 2, 64),
      size: Vector2(300, 192),
      text: 'Trolls',
    );
    add(resourceBanner);

    // Create the 9-slice button at 128x128
    // Position it at the bottom center of the screen
    spawnButton = Button(
      position: Vector2(size.x / 2, size.y - 64), // Bottom center, 64 pixels from bottom
      size: Vector2(128, 128),
      onPressed: _onButtonPressed,
      animation: SpriteAnimation.fromFrameData(imageIdle, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/15, textureSize: Vector2(128, 128), loop: true)),
    );
    add(spawnButton);
  }

  void _onButtonPressed() {
    final position = _generateRandomPosition();
    final sheep = Sheep(position: position, size: Vector2(128, 128));
    sheep.troll = troll;
    add(sheep);
    print('Button pressed!');
  }

  Vector2 _generateRandomPosition() {
    const minDistance = 200.0;
    const margin = 64.0; // Keep sheep away from edges (half of sheep size)
    
    Vector2 position;
    int attempts = 0;
    const maxAttempts = 100;
    
    do {
      position = Vector2(
        margin + random.nextDouble() * (size.x - 2 * margin),
        margin + random.nextDouble() * (size.y - 2 * margin),
      );
      attempts++;
    } while (
      position.distanceTo(troll.position) < minDistance &&
      attempts < maxAttempts
    );
    
    return position;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    troll.moveTo(event.localPosition);
  }
}
