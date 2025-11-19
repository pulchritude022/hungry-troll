import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'dart:math';
import 'troll.dart';
import 'meat.dart';
import '../state/game_state.dart';

enum SheepState { idle, move, grass, bounce }

class Sheep extends SpriteAnimationGroupComponent<SheepState> with HasGameReference<FlameGame> {
  Troll? troll;  // Reference to check distance
  GameState? gameState;  // Reference to update sheep count
  bool isFleeing = false;  // Prevent constant recalculation while already fleeing
  bool _isCaught = false;  // Prevent multiple meat spawns from same sheep
  static const fleeDistance = 200.0;
  static const catchDistance = 120.0;  // Distance at which troll catches sheep
  static const fleeSpeed = 50.0;  // 50% slower than troll's 100 speed
  
  Sheep({
    required super.position,
    required super.size
  }) : super(
    current: SheepState.bounce,
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
    final imageBounce = await game.images.load('resources/sheep/happysheep_bouncing.png');

    animations = {
      SheepState.idle: SpriteAnimation.fromFrameData(imageIdle, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      SheepState.move: SpriteAnimation.fromFrameData(imageMove, SpriteAnimationData.sequenced(amount: 4, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      SheepState.grass: SpriteAnimation.fromFrameData(imageGrass, SpriteAnimationData.sequenced(amount: 12, stepTime: 1/frameRate, textureSize: frameSize, loop: true)),
      SheepState.bounce: SpriteAnimation.fromFrameData(imageBounce, SpriteAnimationData.sequenced(amount: 6, stepTime: 1/frameRate, textureSize: frameSize, loop: false)),
    };
    
    // Listen for when bounce animation completes
    animationTicker?.onComplete = onBounceComplete;
  }

  @override
  void update(double dt) {
    super.update(dt);

    priority = position.y.toInt();
    
    // Check if troll is nearby
    if (troll != null) {
      final distanceToTroll = position.distanceTo(troll!.position);
      
      // If troll is within catch distance, sheep disappears (gets eaten)
      if (distanceToTroll < catchDistance && !_isCaught) {
        _isCaught = true;
        
        final dropAmount = gameState?.meatDropAmount ?? 1;
        final random = Random();
        
        for (var i = 0; i < dropAmount; i++) {
          // Random offset within 64x64 area (-32 to +32)
          final offset = Vector2(
            (random.nextDouble() - 0.5) * 64,
            (random.nextDouble() - 0.5) * 64,
          );
          
          final meat = Meat(position: position + offset, size: Vector2(128, 128));
          meat.troll = troll;
          meat.gameState = gameState;
          game.add(meat);
        }

        gameState?.decrementSheep();
        removeFromParent();
        return;
      }
      
      // If troll is within flee distance and not already fleeing, run away
      if (distanceToTroll < fleeDistance && !isFleeing) {
        // Calculate direction away from troll
        final fleeDirection = (position - troll!.position).normalized();
        final fleeTarget = position + (fleeDirection * fleeDistance);
        
        // Clamp to game bounds        
        const topMargin = 150.0;
        const bottomMargin = 250.0;
        const sideMargin = 120.0;
        final clampedTarget = Vector2(
          fleeTarget.x.clamp(sideMargin, game.size.x - sideMargin),
          fleeTarget.y.clamp(topMargin, game.size.y - bottomMargin),
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

  void onBounceComplete() {
    if (current == SheepState.bounce) {
      current = SheepState.idle;
      // Clear the onComplete callback so it doesn't interfere with looping animations
      animationTicker?.onComplete = null;
    }
  }

}

