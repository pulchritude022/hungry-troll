import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'button.dart';
import '../data/upgrades_data.dart';

class UpgradeButton extends Button {
  final String upgradeId;
  late TextComponent _labelComponent;
  late TextComponent _costComponent;
  late TextComponent _valueComponent;

  UpgradeButton({
    required this.upgradeId,
    required super.position,
  }) : super(
          buttonType: ButtonType.red,
          size: Vector2(120, 120),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final definition = Upgrades.get(upgradeId);

    // Upgrade Name
    _labelComponent = TextComponent(
      text: definition.name,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'BearDays',
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2 - 30),
      anchor: Anchor.center,
    );
    add(_labelComponent);

    // Level Display
    _valueComponent = TextComponent(
      text: '0 -> 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 32,
          fontFamily: 'BearDays',
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
    add(_valueComponent);

    // Cost Display
    _costComponent = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'BearDays',
        ),
      ),
      position: Vector2(size.x / 2, size.y / 2 + 30),
      anchor: Anchor.center,
    );
    add(_costComponent);

    _updateDisplay();
    game.gameState.addListener(_updateDisplay);
  }

  @override
  void onRemove() {
    game.gameState.removeListener(_updateDisplay);
    super.onRemove();
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    final definition = Upgrades.get(upgradeId);
    
    if (game.upgradeService.canAfford(definition)) {
      game.upgradeService.purchase(definition);
      // UI update happens via listener
    }
  }

  void _updateDisplay() {
    final definition = Upgrades.get(upgradeId);
    final currentLevel = game.gameState.upgradeState.getUpgradeLevel(upgradeId);
    final isMaxLevel = currentLevel >= definition.levels.length - 1;
    final currentValue = definition.getValue(currentLevel);
    final nextValue = definition.getValue(currentLevel + 1);

    _valueComponent.text = '+${nextValue - currentValue}';

    if (isMaxLevel) {
      _costComponent.text = 'MAX';
      _costComponent.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontFamily: 'BearDays',
        ),
      );
      disable();
    } else {
      final nextCosts = game.upgradeService.getNextLevelCost(definition);
      // Simple display for now, assuming mostly single cost type or just showing the first
      if (nextCosts.isNotEmpty) {
        final cost = nextCosts.first;
        _costComponent.text = '${cost.amount} ${cost.type.name}';
        
        final canAfford = game.upgradeService.canAfford(definition);
        
        if (canAfford) {
          enable();
        } else {
          disable();
        }
      } else {
         // Should be max level if no costs, but handle gracefully
         _costComponent.text = 'FREE';
         enable();
      }
    }
  }
}

