import 'package:flutter/foundation.dart';

class UpgradeState extends ChangeNotifier {
  final Map<String, int> _upgradeLevels = {};

  int getUpgradeLevel(String upgradeId) {
    return _upgradeLevels[upgradeId] ?? 0;
  }

  void setUpgradeLevel(String upgradeId, int level) {
    _upgradeLevels[upgradeId] = level;
    notifyListeners();
  }

  void incrementUpgradeLevel(String upgradeId) {
    final current = getUpgradeLevel(upgradeId);
    setUpgradeLevel(upgradeId, current + 1);
  }

  void reset() {
    _upgradeLevels.clear();
    notifyListeners();
  }
}

