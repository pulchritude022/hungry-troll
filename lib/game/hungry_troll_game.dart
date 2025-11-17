import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/troll.dart';
import '../components/sheep.dart';
import '../components/meat.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GameWidget(game: HungryTrollGame()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              color: const Color.fromARGB(255, 71, 71, 71),
              child: Center(
                child: ButtonWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonWidget extends StatefulWidget {
  @override
  _ButtonWidgetState createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => isPressed = true);
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
    final sheep = Sheep(position: event.localPosition, size: Vector2(128, 128));
    sheep.troll = troll;
    add(sheep);
    //final meat = Meat(position: event.localPosition, size: Vector2(128, 128));
    //add(meat);
    troll.moveTo(event.localPosition);
  }
}
