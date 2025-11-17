import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'troll.dart';
import 'meat.dart';

enum SheepState { idle, move, grass }

class Sheep extends SpriteAnimationGroupComponent<SheepState> with HasGameReference<FlameGame> {
  Troll? troll;  // Reference to check distance
  bool isFleeing = false;  // Prevent constant recalculation while already fleeing
  static const fleeDistance = 200.0;
  static const catchDistance = 100.0;  // Distance at which troll catches sheep
  static const fleeSpeed = 50.0;  // 50% slower than troll's 100 speed
  
  Sheep({
    required super.position,
    required super.size
  }) : super(
    current: SheepState.idle,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final frameSize = Vector2(128, 128);
    const frameRate = 15;
    final imageIdle = await game.images.load('free_pack/decorations/sheep/sheep_idle.png');
    final imageMove = await game.images.load('free_pack/decorations/sheep/sheep_move.png');
    final imageGrass = await game.images.load('free_pack/decorations/sheep/sheep_grass.png');

    animations = {
      SheepState.idle: SpriteAnimation.fromFrameData(imageIdle, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      SheepState.move: SpriteAnimation.fromFrameData(imageMove, SpriteAnimationData.sequenced(amount: 4, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      SheepState.grass: SpriteAnimation.fromFrameData(imageGrass, SpriteAnimationData.sequenced(amount: 12, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
    };
  }

  @override
  void update(double dt) {
    super.update(dt);

    priority = position.y.toInt();
    
    // Check if troll is nearby
    if (troll != null) {
      final distanceToTroll = position.distanceTo(troll!.position);
      
      // If troll is within catch distance, sheep disappears (gets eaten)
      if (distanceToTroll < catchDistance) {
        // Spawn meat at sheep's position before removing sheep
        final meat = Meat(position: position.clone(), size: Vector2(128, 128));
        game.add(meat);
        removeFromParent();
        return;
      }
      
      // If troll is within flee distance and not already fleeing, run away
      if (distanceToTroll < fleeDistance && !isFleeing) {
        // Calculate direction away from troll
        final fleeDirection = (position - troll!.position).normalized();
        final fleeTarget = position + (fleeDirection * fleeDistance);
        
        // Clamp to game bounds
        final clampedTarget = Vector2(
          fleeTarget.x.clamp(50, game.size.x - 50),
          fleeTarget.y.clamp(50, game.size.y - 50),
        );
        
        fleeTo(clampedTarget);
      }
    }
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
    
    current = SheepState.move;
    final moveEffect = MoveToEffect(position, EffectController(duration: duration), onComplete: onMoveComplete);
    add(moveEffect);
  }

  void onMoveComplete() {
    current = SheepState.grass;
    add(
      TimerComponent(
        period: 2.0,
        onTick: () => current = SheepState.idle,
      ),
    );
  }

  void fleeTo(Vector2 position) {
    // Remove any existing MoveEffect
    children.query<MoveEffect>().forEach((effect) => effect.removeFromParent());

    final distance = position.distanceTo(this.position);
    final duration = distance / fleeSpeed;
    
    // Flip sprite based on movement direction
    if (position.x < this.position.x) {
      // Moving left - flip the sprite horizontally
      scale.x = -1;
    } else {
      // Moving right - face right (normal orientation)
      scale.x = 1;
    }
    
    isFleeing = true;
    current = SheepState.move;
    final moveEffect = MoveToEffect(position, EffectController(duration: duration), onComplete: onFleeComplete);
    add(moveEffect);
  }

  void onFleeComplete() {
    isFleeing = false;
    current = SheepState.idle;
  }

}

