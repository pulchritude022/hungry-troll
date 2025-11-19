import '../models/upgrade_definition.dart';
import '../models/upgrade_cost.dart';
import '../models/resource_type.dart';
import '../state/game_state.dart';
import '../state/upgrade_state.dart';

class UpgradeService {
  final GameState gameState;
  final UpgradeState upgradeState;

  UpgradeService(this.gameState, this.upgradeState);

  List<UpgradeCost> getNextLevelCost(UpgradeDefinition upgrade) {
    final currentLevel = upgradeState.getUpgradeLevel(upgrade.id);
    final nextLevel = currentLevel + 1;
    
    if (nextLevel >= upgrade.levels.length) {
      return []; // Max level reached
    }
    
    return upgrade.levels[nextLevel].cost;
  }

  bool canAfford(UpgradeDefinition upgrade) {
    final currentLevel = upgradeState.getUpgradeLevel(upgrade.id);
    final nextLevel = currentLevel + 1;

    if (nextLevel >= upgrade.levels.length) return false;

    final costs = upgrade.levels[nextLevel].cost;
    
    for (final cost in costs) {
      switch (cost.type) {
        case ResourceType.meat:
          if (gameState.meat < cost.amount) return false;
          break;
        case ResourceType.gold:
          if (gameState.gold < cost.amount) return false;
          break;
      }
    }
    
    return true;
  }

  void purchase(UpgradeDefinition upgrade) {
    if (!canAfford(upgrade)) return;

    final costs = getNextLevelCost(upgrade);

    for (final cost in costs) {
      switch (cost.type) {
        case ResourceType.meat:
          gameState.spendMeat(cost.amount);
          break;
        case ResourceType.gold:
          gameState.spendGold(cost.amount);
          break;
      }
    }

    upgradeState.incrementUpgradeLevel(upgrade.id);
  }

  double getEffectiveValue(UpgradeDefinition upgrade) {
    final level = upgradeState.getUpgradeLevel(upgrade.id);
    return upgrade.getValue(level);
  }
}
