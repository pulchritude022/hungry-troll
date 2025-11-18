import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/button.dart';

/// Example game to test the 9-slice scaled Button component at various sizes
/// 
/// This demonstrates that the button scales correctly at:
/// - Smaller sizes (< 192x192): Corners overlap appropriately
/// - Original size (192x192): Renders as expected
/// - Larger sizes (> 192x192): Edges tile and center fills properly
/// - Mixed sizes: Different widths and heights work correctly
class ButtonTestGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Test 1: Small button (100x100) - smaller than 192x192
    // Corners should overlap and adapt
    final smallButton = Button(
      position: Vector2(200, 200),
      size: Vector2(100, 100),
      onPressed: () => print('Small button pressed'),
    );
    add(smallButton);

    // Test 2: Very small button (80x80) - much smaller than 192x192
    // Should handle extreme scaling down
    final verySmallButton = Button(
      position: Vector2(400, 200),
      size: Vector2(80, 80),
      onPressed: () => print('Very small button pressed'),
    );
    add(verySmallButton);

    // Test 3: Original size (192x192) - exact sprite size
    // Should render perfectly at native resolution
    final originalButton = Button(
      position: Vector2(600, 200),
      size: Vector2(192, 192),
      onPressed: () => print('Original size button pressed'),
    );
    add(originalButton);

    // Test 4: Large button (300x300) - larger than 192x192
    // Edges should tile, center should fill
    final largeButton = Button(
      position: Vector2(1000, 200),
      size: Vector2(300, 300),
      onPressed: () => print('Large button pressed'),
    );
    add(largeButton);

    // Test 5: Very large button (400x200) - much larger, different aspect ratio
    // Width > 192, height > 192, but different proportions
    final wideButton = Button(
      position: Vector2(400, 600),
      size: Vector2(400, 200),
      onPressed: () => print('Wide button pressed'),
    );
    add(wideButton);

    // Test 6: Tall button (150x300) - mixed dimensions
    // Width < 192, height > 192
    final tallButton = Button(
      position: Vector2(800, 600),
      size: Vector2(150, 300),
      onPressed: () => print('Tall button pressed'),
    );
    add(tallButton);

    // Test 7: Wide but short button (350x120) - mixed dimensions
    // Width > 192, height < 192
    final shortWideButton = Button(
      position: Vector2(200, 800),
      size: Vector2(350, 120),
      onPressed: () => print('Short wide button pressed'),
    );
    add(shortWideButton);

    // Test 8: Extreme rectangle (500x100) - very wide, very short
    // Tests extreme aspect ratio handling
    final extremeButton = Button(
      position: Vector2(800, 800),
      size: Vector2(500, 100),
      onPressed: () => print('Extreme button pressed'),
    );
    add(extremeButton);

    // Add text labels for each test case
    await _addTestLabels();
  }

  Future<void> _addTestLabels() async {
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 12,
      ),
    );

    final labels = [
      ('Small\n100x100', Vector2(100, 170)),
      ('Very Small\n80x80', Vector2(250, 155)),
      ('Original\n192x192', Vector2(400, 210)),
      ('Large\n300x300', Vector2(150, 470)),
      ('Wide\n400x200', Vector2(400, 520)),
      ('Tall\n150x300', Vector2(100, 720)),
      ('Short Wide\n350x120', Vector2(400, 730)),
      ('Extreme\n500x100', Vector2(300, 870)),
    ];

    for (final (text, position) in labels) {
      add(
        TextComponent(
          text: text,
          position: position,
          textRenderer: textPaint,
          anchor: Anchor.center,
        ),
      );
    }
  }
}

