import '../models/upgrade_definition.dart';
import '../models/upgrade_level.dart';
import '../models/upgrade_cost.dart';
import '../models/resource_type.dart';

class Upgrades {
  static const String maxSheepCount = 'max_sheep_count';
  static const String sheepPerSpawn = 'sheep_per_spawn';
  static const String meatDropAmount = 'meat_drop_amount';

  static final List<UpgradeDefinition> all = [
    UpgradeDefinition(
      id: maxSheepCount,
      name: 'Max Sheep',
      description: 'Increases the maximum number of sheep allowed at once.',
      levels: [
        const UpgradeLevel(value: 1.0, cost: []),
        const UpgradeLevel(value: 2.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 3)]),
        const UpgradeLevel(value: 3.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 5)]),
        const UpgradeLevel(value: 5.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 8)]),
        const UpgradeLevel(value: 7.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 12)]),
        const UpgradeLevel(value: 10.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 20)]),
        const UpgradeLevel(value: 15.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 30)]),
        const UpgradeLevel(value: 20.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 50)]),
        const UpgradeLevel(value: 30.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 100)]),
        const UpgradeLevel(value: 40.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 200)]),
        const UpgradeLevel(value: 50.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 300)]),
        const UpgradeLevel(value: 100.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 1000)]),
      ],
    ),
    UpgradeDefinition(
      id: sheepPerSpawn,
      name: 'Click',
      description: 'Spawns additional sheep per click.',
      levels: [
        const UpgradeLevel(value: 1.0, cost: []),
        const UpgradeLevel(value: 2.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 50)]),
        const UpgradeLevel(value: 3.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 70)]),
        const UpgradeLevel(value: 4.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 100)]),
        const UpgradeLevel(value: 5.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 150)]),
        const UpgradeLevel(value: 10.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 250)]),
      ],
    ),
    UpgradeDefinition(
      id: meatDropAmount,
      name: 'Meat',
      description: 'Increases the amount of meat dropped by sheep.',
      levels: [
        const UpgradeLevel(value: 1.0, cost: []),
        const UpgradeLevel(value: 2.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 100)]),
        const UpgradeLevel(value: 3.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 200)]),
        const UpgradeLevel(value: 4.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 500)]),
        const UpgradeLevel(value: 5.0, cost: [UpgradeCost(type: ResourceType.meat, amount: 1000)]),
      ],
    ),
  ];

  static UpgradeDefinition get(String id) {
    return all.firstWhere((u) => u.id == id, orElse: () => throw Exception('Upgrade not found: $id'));
  }
}
