import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../components/troll.dart';

void main() {
  runApp(GameWidget(game: HungryTrollGame()));
}



class HungryTrollGame extends FlameGame with TapCallbacks {
  late Troll troll;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();

    final frameSize = Vector2(384, 384);
    const imageScale = 0.5;

    troll = Troll(position: Vector2(200,200), size: frameSize*imageScale);
    add(troll);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print('Tap down');
    print('Event: ${event.localPosition}');
    troll.moveTo(event.localPosition);
  }
}
