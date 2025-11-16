import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

void main() {
  runApp(GameWidget(game: HungryTrollGame()));
}

class HungryTrollGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleComponent(size: Vector2.all(200), paint: Paint()..color = Colors.blue));
  }
}
