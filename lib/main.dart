import 'package:flutter/material.dart';
import 'game/hungry_troll_game.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hide the status bar and navigation bar for a full-screen experience
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'BearDays',
    ),
    home: Scaffold(
      body: GameScreen(),
    ),
  ));
}

