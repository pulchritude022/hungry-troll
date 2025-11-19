import 'package:flutter/foundation.dart';

/// Game state that tracks currencies and active entities
class GameState extends ChangeNotifier {
  int _meat = 0;
  int _gold = 0;
  int _sheepCount = 0;
  int _sheepMaxCount = 3;

  int get meat => _meat;
  int get gold => _gold;
  int get sheepCount => _sheepCount;
  int get sheepMaxCount => _sheepMaxCount;

  void addMeat(int amount) {
    _meat += amount;
    notifyListeners();
  }

  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  bool canSpawnSheep() {
    return _sheepCount < _sheepMaxCount;
  }

  void incrementSheep() {
    _sheepCount++;
    notifyListeners();
  }

  void decrementSheep() {
    _sheepCount--;
    notifyListeners();
  }

  void setSheepMaxCount(int maxCount) {
    _sheepMaxCount = maxCount;
    notifyListeners();
  }

  void reset() {
    _meat = 0;
    _gold = 0;
    _sheepCount = 0;
    _sheepMaxCount = 3;
    notifyListeners();
  }
}

