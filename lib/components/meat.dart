import 'package:flame/components.dart';
import 'package:flame/game.dart';

enum MeatState { spawn, idle }

class Meat extends SpriteAnimationGroupComponent<MeatState> with HasGameReference<FlameGame> {
  Meat({
    required super.position,
    required super.size
  }) : super(
    current: MeatState.spawn,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final frameSize = Vector2(128, 128);
    const frameRate = 15;
    final imageSpawn = await game.images.load('resources/resources/m_spawn.png');
    final imageIdle = await game.images.load('resources/resources/m_idle.png');

    animations = {
      MeatState.spawn: SpriteAnimation.fromFrameData(
        imageSpawn, 
        SpriteAnimationData.sequenced(
          amount: 7, 
          stepTime: 1/frameRate, 
          textureSize: frameSize, 
          loop: false
        ),
      ),
      MeatState.idle: SpriteAnimation.fromFrameData(
        imageIdle, 
        SpriteAnimationData.sequenced(
          amount: 1, 
          stepTime: 1/frameRate, 
          textureSize: frameSize, 
          loop: false
        ),
      ),
    };

    // Listen for when spawn animation completes
    animationTicker?.onComplete = onSpawnComplete;
  }

  @override
  void update(double dt) {
    super.update(dt);
    priority = position.y.toInt();
  }

  void onSpawnComplete() {
    if (current == MeatState.spawn) {
      current = MeatState.idle;
      // Set up the idle animation ticker
      animationTicker?.onComplete = null;
    }
  }
}

