import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';

enum TrollState { idle, walk, attack, recovery, dead }



class Troll extends SpriteAnimationGroupComponent<TrollState> with HasGameReference<FlameGame> {
  Troll({
    required super.position,
    required super.size
  }) : super(
    current: TrollState.idle,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final frameSize = Vector2(384, 384);
    const frameRate = 15;
    final imageIdle = await game.images.load('enemy_pack/troll/troll_idle.png');
    final imageWalk = await game.images.load('enemy_pack/troll/troll_walk.png');
    final imageAttack = await game.images.load('enemy_pack/troll/troll_attack.png');
    final imageRecovery = await game.images.load('enemy_pack/troll/troll_recovery.png');
    final imageDead = await game.images.load('enemy_pack/troll/troll_dead.png');

    animations = {
      TrollState.idle: SpriteAnimation.fromFrameData(imageIdle, SpriteAnimationData.sequenced(amount: 12, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      TrollState.walk: SpriteAnimation.fromFrameData(imageWalk, SpriteAnimationData.sequenced(amount: 10, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      TrollState.attack: SpriteAnimation.fromFrameData(imageAttack, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      TrollState.recovery: SpriteAnimation.fromFrameData(imageRecovery, SpriteAnimationData.sequenced(amount: 10, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      TrollState.dead: SpriteAnimation.fromFrameData(imageDead, SpriteAnimationData.sequenced(amount: 10, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
    };
  }

  void moveTo(Vector2 position) {
    // Remove any existing MoveEffect
    children.query<MoveEffect>().forEach((effect) => effect.removeFromParent());

    final distance = position.distanceTo(this.position);
    final duration = distance / 100;
    
    // Flip sprite based on movement direction
    if (position.x < this.position.x) {
      // Moving left - flip the sprite horizontally
      scale.x = -1;
    } else {
      // Moving right - face right (normal orientation)
      scale.x = 1;
    }
    
    current = TrollState.walk;
    final moveEffect = MoveToEffect(position, EffectController(duration: duration), onComplete: onMoveComplete);
    add(moveEffect);
  }

  void onMoveComplete() {
    current = TrollState.recovery;
    add(
      TimerComponent(
        period: 2.0,
        onTick: () => current = TrollState.idle,
      ),
    );
  }

}