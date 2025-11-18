# 9-Slice Button Component Test

This directory contains a test example for the 9-slice scaled Button component.

## Implementation Details

The `Button` component in `lib/components/button.dart` uses Flame's `NineTileBox` to implement 9-slice scaling. This allows the button to scale to any arbitrary size while maintaining proper corner and edge rendering.

### How 9-Slice Scaling Works

The 192x192 button sprite is divided into a 3x3 grid:
- **Corner tiles** (64x64 each): 4 corners that remain fixed size
- **Edge tiles** (64x64 each): 4 edges that scale in one direction
- **Center tile** (64x64): 1 center that scales in both directions

### Scaling Behavior

1. **Larger than 192x192**: Edges are tiled/repeated as needed, center fills the middle area
2. **Smaller than 192x192**: Corners overlap with fractional edge pieces as needed
3. **Mixed dimensions**: Each dimension scales independently (e.g., width < 192, height > 192)

## Test Cases

The `ButtonTestGame` in `lib/examples/button_test_example.dart` demonstrates 8 different test cases:

1. **Small (100x100)**: Both dimensions smaller - corners adapt and overlap
2. **Very Small (80x80)**: Extreme downscaling - tests minimum size handling
3. **Original (192x192)**: Native resolution - perfect 1:1 rendering
4. **Large (300x300)**: Both dimensions larger - edges tile, center fills
5. **Wide (400x200)**: Width > 192, height > 192 - different aspect ratio
6. **Tall (150x300)**: Width < 192, height > 192 - mixed scaling
7. **Short Wide (350x120)**: Width > 192, height < 192 - opposite mixed scaling
8. **Extreme (500x100)**: Very wide, very short - extreme aspect ratio

## Usage

To use the Button component in your game:

```dart
final button = Button(
  position: Vector2(100, 100),
  size: Vector2(200, 150),  // Can be any size!
  onPressed: () => print('Button pressed!'),
);
add(button);
```

## Running the Test

To run the test example, create a Flutter app that uses `ButtonTestGame` as the game:

```dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'lib/examples/button_test_example.dart';

void main() {
  runApp(
    GameWidget(
      game: ButtonTestGame(),
    ),
  );
}
```

## Verification Results

✅ The Button component correctly handles:
- Scaling down below the source sprite size (192x192)
- Rendering at the original sprite size
- Scaling up above the source sprite size
- Mixed dimensions (one dimension larger, one smaller)
- Extreme aspect ratios

The NineTileBox automatically handles all the complex logic for:
- Tiling edges when destination is larger
- Overlapping corners when destination is smaller
- Scaling the center tile to fill the available space

