import 'package:flutter/foundation.dart';
import '../data/upgrades_data.dart';
import 'upgrade_state.dart';

/// Game state that tracks currencies and active entities
class GameState extends ChangeNotifier {
  int _meat = 0;
  int _gold = 0;
  int _sheepCount = 0;
  // _sheepMaxCount is now derived from upgrades
  
  final UpgradeState upgradeState = UpgradeState();

  GameState() {
    // Forward upgrade state changes to game state listeners
    upgradeState.addListener(notifyListeners);
  }

  int get meat => _meat;
  int get gold => _gold;
  int get sheepCount => _sheepCount;
  
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
    _meat += amount;
    notifyListeners();
  }
  
  void spendMeat(int amount) {
    if (_meat >= amount) {
      _meat -= amount;
      notifyListeners();
    }
  }

  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }
  
  void spendGold(int amount) {
    if (_gold >= amount) {
      _gold -= amount;
      notifyListeners();
    }
  }

  bool canSpawnSheep() {
    return _sheepCount < sheepMaxCount;
  }

  void incrementSheep() {
    _sheepCount++;
    notifyListeners();
  }

  void decrementSheep() {
    _sheepCount--;
    notifyListeners();
  }

  @override
  void dispose() {
    upgradeState.removeListener(notifyListeners);
    upgradeState.dispose();
    super.dispose();
  }

  void reset() {
    _meat = 0;
    _gold = 0;
    _sheepCount = 0;
    upgradeState.reset();
    notifyListeners();
  }
}
