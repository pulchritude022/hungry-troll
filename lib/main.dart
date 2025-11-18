import 'package:flutter/material.dart';
import 'game/hungry_troll_game.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'BearDays',
    ),
    home: Scaffold(
      body: GameScreen(),
    ),
  ));
}

