import 'package:flutter/material.dart';
import '../game/hungry_troll_game.dart';
import '../state/game_state.dart';
import '../data/upgrades_data.dart';
import 'components/resource_banner.dart';
import 'components/sheep_spawn_button.dart';
import 'components/upgrade_button.dart';

class GameOverlay extends StatelessWidget {
  final HungryTrollGame game;
  final GameState gameState;

  const GameOverlay({
    super.key,
    required this.game,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Resource Banner (Top Center)
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0), // Adjust margin as needed
            child: ResourceBanner(gameState: gameState),
          ),
        ),

        // Sheep Spawn Button (Bottom Center)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0), // Adjust margin
            child: SheepSpawnButton(
              game: game,
              gameState: gameState,
            ),
          ),
        ),

        // Upgrade Buttons (Center Right)
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                UpgradeButton(
                  upgradeId: Upgrades.maxSheepCount,
                  game: game,
                  gameState: gameState,
                ),
                const SizedBox(height: 10),
                UpgradeButton(
                  upgradeId: Upgrades.sheepPerSpawn,
                  game: game,
                  gameState: gameState,
                ),
                const SizedBox(height: 10),
                UpgradeButton(
                  upgradeId: Upgrades.meatDropAmount,
                  game: game,
                  gameState: gameState,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

