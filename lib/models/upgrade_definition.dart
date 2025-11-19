import 'upgrade_level.dart';

class UpgradeDefinition {
  final String id;
  final String name;
  final String description;
  final List<UpgradeLevel> levels;
  final String category;

  const UpgradeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.levels,
    this.category = 'general',
  });

  int get maxLevel => levels.length - 1;

  /// Helper to get the value at a specific level
  double getValue(int level) {
    if (level < 0 || level >= levels.length) {
      // Fallback to last defined level or first if strictly out of bounds?
      // Safest is to clamp to range.
      if (levels.isEmpty) return 0.0;
      if (level < 0) return levels.first.value;
      return levels.last.value;
    }
    return levels[level].value;
  }
}
