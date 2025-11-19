import 'upgrade_cost.dart';

class UpgradeLevel {
  final List<UpgradeCost> cost;
  final double value;
  final String? description; // Optional overrides for specific level descriptions

  const UpgradeLevel({
    required this.value,
    this.cost = const [], // Level 0 usually has no cost
    this.description,
  });
}

