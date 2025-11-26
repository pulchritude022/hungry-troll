import 'package:flutter/foundation.dart';
import '../data/upgrades_data.dart';
import 'upgrade_state.dart';

/// Game state that tracks currencies and active entities
class GameState extends ChangeNotifier {
  final ValueNotifier<int> meat = ValueNotifier<int>(0);
  final ValueNotifier<int> gold = ValueNotifier<int>(0);
  final ValueNotifier<int> sheepCount = ValueNotifier<int>(0);
  
  // _sheepMaxCount is now derived from upgrades
  
  final UpgradeState upgradeState = UpgradeState();

  GameState() {
    // Forward upgrade state changes to game state listeners
    upgradeState.addListener(notifyListeners);
  }

  // --- Upgrade Value Getters ---
  
  /// Generic helper to get the current effective value of any upgrade
  double getUpgradeValue(String upgradeId) {
    final level = upgradeState.getUpgradeLevel(upgradeId);
    return Upgrades.get(upgradeId).getValue(level);
  }

  int get sheepMaxCount => getUpgradeValue(Upgrades.maxSheepCount).toInt();
  
  int get sheepPerSpawn => getUpgradeValue(Upgrades.sheepPerSpawn).toInt();
  
  int get meatDropAmount => getUpgradeValue(Upgrades.meatDropAmount).toInt();

  // -----------------------------

  void addMeat(int amount) {
    meat.value += amount;
  }
  
  void spendMeat(int amount) {
    if (meat.value >= amount) {
      meat.value -= amount;
    }
  }

  void addGold(int amount) {
    gold.value += amount;
  }
  
  void spendGold(int amount) {
    if (gold.value >= amount) {
      gold.value -= amount;
    }
  }

  bool canSpawnSheep() {
    return sheepCount.value < sheepMaxCount;
  }

  void incrementSheep() {
    sheepCount.value++;
  }

  void decrementSheep() {
    sheepCount.value--;
  }

  @override
  void dispose() {
    meat.dispose();
    gold.dispose();
    sheepCount.dispose();
    upgradeState.removeListener(notifyListeners);
    upgradeState.dispose();
    super.dispose();
  }

  void reset() {
    meat.value = 0;
    gold.value = 0;
    sheepCount.value = 0;
    upgradeState.reset();
    notifyListeners(); // Keep this one as it affects general state listeners if any
  }
}
