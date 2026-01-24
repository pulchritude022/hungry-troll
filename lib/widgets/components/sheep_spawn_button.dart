import 'package:flame/widgets.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../game/hungry_troll_game.dart';
import '../../state/game_state.dart';
import '../common/nine_slice_button.dart';
import '../../components/sheep.dart'; 

class SheepSpawnButton extends StatefulWidget {
  final HungryTrollGame game;
  final GameState gameState;

  const SheepSpawnButton({
    super.key,
    required this.game,
    required this.gameState,
  });

  @override
  State<SheepSpawnButton> createState() => _SheepSpawnButtonState();
}

class _SheepSpawnButtonState extends State<SheepSpawnButton> {
  Future<SpriteAnimation>? _animationFuture;

  @override
  void initState() {
    super.initState();
    _animationFuture = _loadAnimation();
  }

  Future<SpriteAnimation> _loadAnimation() async {
    // We can use widget.game.images or Flame.images
    final image = await widget.game.images.load('free_pack/decorations/sheep/sheep_idle.png');
    final textureSize = Vector2(128, 128);
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: 1 / 15,
        textureSize: textureSize,
        loop: true,
      ),
    );
  }

  void _handleTap() {
    final spawnCount = widget.gameState.sheepPerSpawn;
    int spawned = 0;

    for (int i = 0; i < spawnCount; i++) {
      if (widget.gameState.canSpawnSheep()) {
        final position = widget.game.generateSpawnPosition();
        final sheep = Sheep(position: position, size: Vector2(128, 128));
        sheep.troll = widget.game.troll;
        sheep.gameState = widget.gameState;
        
        widget.gameState.incrementSheep();
        // Add sheep to the game world (not directly to the game)
        widget.game.gameWorld.add(sheep);
        spawned++;
      } else {
        break;
      }
    }

    if (spawned > 0) {
      debugPrint('Spawned $spawned sheep.');
    } else {
      debugPrint('Cannot spawn sheep!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.gameState.sheepCount,
      builder: (context, currentSheepCount, _) {
        final maxSheep = widget.gameState.sheepMaxCount;
        final canSpawn = widget.gameState.canSpawnSheep();

        return NineSliceButton(
          type: ButtonType.blue,
          width: 160,
          height: 160,
          disabled: !canSpawn,
          onTap: canSpawn ? _handleTap : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sheep Animation
              SizedBox(
                width: 96,
                height: 96,
                child: FutureBuilder<SpriteAnimation>(
                  future: _animationFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SpriteAnimationWidget(
                        animation: snapshot.data!,
                        animationTicker: snapshot.data!.createTicker(),
                        playing: true,
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              const SizedBox(height: 4),
              // Count Text
              Text(
                '$currentSheepCount/$maxSheep',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'BearDays',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
