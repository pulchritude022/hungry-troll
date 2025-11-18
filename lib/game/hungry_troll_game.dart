import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/troll.dart';
import '../components/sheep.dart';

class GameScreen extends StatelessWidget {
  final HungryTrollGame game = HungryTrollGame();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Game area - expands to fill available space above button
        Expanded(
          child: GameWidget(game: game),
        ),
        // Button area - fixed height at bottom
        Container(
          height: 100,
          color: const Color.fromARGB(255, 71, 71, 71),
          child: Center(
            child: ButtonWidget(game: game),
          ),
        ),
      ],
    );
  }
}

class ButtonWidget extends StatefulWidget {
  final HungryTrollGame game;

  const ButtonWidget({Key? key, required this.game}) : super(key: key);

  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool isPressed = false;
  final Random random = Random();

  Vector2 _generateRandomPosition() {
    const minDistance = 200.0;
    const margin = 64.0; // Keep sheep away from edges (half of sheep size)
    
    Vector2 position;
    int attempts = 0;
    const maxAttempts = 100;
    
    do {
      position = Vector2(
        margin + random.nextDouble() * (widget.game.size.x - 2 * margin),
        margin + random.nextDouble() * (widget.game.size.y - 2 * margin),
      );
      attempts++;
    } while (
      position.distanceTo(widget.game.troll.position) < minDistance &&
      attempts < maxAttempts
    );
    
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
        final position = _generateRandomPosition();
        final sheep = Sheep(position: position, size: Vector2(128, 128));
        sheep.troll = widget.game.troll;
        widget.game.add(sheep);
      },
      onTapUp: (_) {
        setState(() => isPressed = false);
        // Add your button action here
        print('Button pressed!');
      },
      onTapCancel: () {
        setState(() => isPressed = false);
      },
      child: Image.asset(
        isPressed
            ? 'assets/images/ui/buttons/button_blue_pressed.png'
            : 'assets/images/ui/buttons/button_blue.png',
        width: 64,
        height: 64,
      ),
    );
  }
}



class HungryTrollGame extends FlameGame with TapCallbacks {
  late Troll troll;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final frameSize = Vector2(384, 384);
    const imageScale = 1.0;

    troll = Troll(position: Vector2(200,200), size: frameSize*imageScale);
    add(troll);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    troll.moveTo(event.localPosition);
  }
}
