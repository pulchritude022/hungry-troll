import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'troll.dart';
import '../state/game_state.dart';

enum MeatState { spawn, idle }

class Meat extends SpriteAnimationGroupComponent<MeatState> with HasGameReference<FlameGame> {
  Troll? troll;  // Reference to check distance
  GameState? gameState;  // Reference to update currency when consumed
  static const pickupDistance = 80.0;  // Distance at which troll picks up meat
  bool _isConsumed = false;  // Flag to prevent double consumption
  TimerComponent? _autoConsumeTimer;  // Reference to cancel timer on manual pickup
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

    checkConsumed();
  }

  void checkConsumed() {
    // Check if troll is nearby and we're not already flying to it
    if (!_isConsumed && troll != null && children.query<MoveEffect>().isEmpty) {
      final distanceToTroll = position.distanceTo(troll!.position);
      
      // If troll is within catch distance, sheep disappears (gets eaten)
      if (distanceToTroll < pickupDistance) {
        consume();
      }
    }
  }

  void consume() {
    if (_isConsumed) return;  // Prevent double consumption
    _isConsumed = true;
    
    // Cancel the auto-consume timer if it exists
    _autoConsumeTimer?.removeFromParent();
    _autoConsumeTimer = null;
    
    final moveEffect = MoveToEffect(troll!.position, EffectController(duration: 0.5, curve: Curves.easeInBack), onComplete: onMoveComplete);
    add(moveEffect);
  }

  void onMoveComplete() {
    gameState?.addMeat(1);
    removeFromParent();
  }

  void onSpawnComplete() {
    if (current == MeatState.spawn) {
      current = MeatState.idle;
      // Set up the idle animation ticker
      animationTicker?.onComplete = null;
      
      // After 5 seconds in idle state, automatically consume the meat
      // Store reference so we can cancel it if manually picked up
      _autoConsumeTimer = TimerComponent(
        period: 5.0,
        removeOnFinish: true,
        onTick: consume,
      );
      add(_autoConsumeTimer!);
    }
  }
}

