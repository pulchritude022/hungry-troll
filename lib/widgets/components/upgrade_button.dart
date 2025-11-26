import 'package:flutter/material.dart';
import '../../game/hungry_troll_game.dart';
import '../../state/game_state.dart';
import '../../data/upgrades_data.dart';
import '../common/nine_slice_button.dart';

class UpgradeButton extends StatelessWidget {
  final String upgradeId;
  final HungryTrollGame game;
  final GameState gameState;

  const UpgradeButton({
    super.key,
    required this.upgradeId,
    required this.game,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final definition = Upgrades.get(upgradeId);

    return ListenableBuilder(
      listenable: Listenable.merge([
        gameState, 
        gameState.meat, 
        gameState.gold
      ]),
      builder: (context, _) {
        final currentLevel = gameState.upgradeState.getUpgradeLevel(upgradeId);
        final isMaxLevel = currentLevel >= definition.levels.length - 1;
        final currentValue = definition.getValue(currentLevel);
        
        // Calculate value increase
        String valueText = '';
        if (!isMaxLevel) {
          final nextValue = definition.getValue(currentLevel + 1);
          valueText = '+${(nextValue - currentValue).toInt()}';
        }

        // Calculate cost text and afford status
        String costText = '';
        bool canAfford = false;

        if (isMaxLevel) {
          costText = 'MAX';
          canAfford = false;
        } else {
          final nextCosts = game.upgradeService.getNextLevelCost(definition);
          if (nextCosts.isNotEmpty) {
            final cost = nextCosts.first;
            costText = '${cost.amount} ${cost.type.name}';
            canAfford = game.upgradeService.canAfford(definition);
          } else {
            costText = 'FREE';
            canAfford = true;
          }
        }

        return NineSliceButton(
          type: ButtonType.red,
          width: 120,
          height: 90,
          disabled: !canAfford && !isMaxLevel, // Disable if can't afford, or fully disable if max?
          // Original logic:
          // if isMaxLevel: disable()
          // if !canAfford: disable()
          // So disabled if either is true.
          // Actually, if isMaxLevel, button should probably just look disabled/maxed.
          
          onTap: (canAfford && !isMaxLevel) 
            ? () => game.upgradeService.purchase(definition) 
            : null,
            
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name
              Text(
                definition.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'BearDays',
                ),
              ),
              // Value Increase
              if (valueText.isNotEmpty)
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'BearDays',
                  ),
                ),
              // Cost
              Text(
                costText,
                style: TextStyle(
                  color: isMaxLevel ? Colors.grey : Colors.white,
                  fontSize: 16,
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

