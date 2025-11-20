import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PerformanceDisplay extends PositionComponent {
  late TextComponent _textComponent;
  
  // Variables for calculating average update time
  double _updateTimeSum = 0;
  int _frameCount = 0;
  double _averageUpdateTime = 0;

  // Variables for calculating FPS
  double _dtSum = 0;
  int _fpsFrameCount = 0;
  double _fps = 0;

  @override
  Future<void> onLoad() async {
    _textComponent = TextComponent(
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16, // Slightly larger for readability
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
    add(_textComponent);
    
    // Set priority to a high value to ensure it renders on top
    priority = 1000; 
  }

  void recordUpdateTime(int microSeconds) {
    _updateTimeSum += microSeconds;
    _frameCount++;
    
    // Update display every 30 frames to avoid flickering
    if (_frameCount >= 30) {
       _averageUpdateTime = _updateTimeSum / _frameCount;
       _updateText();
       _updateTimeSum = 0;
       _frameCount = 0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _dtSum += dt;
    _fpsFrameCount++;

    if (_dtSum >= 0.5) { // Update FPS every 0.5 seconds
      _fps = _fpsFrameCount / _dtSum;
      _updateText();
      _dtSum = 0;
      _fpsFrameCount = 0;
    }
  }

  void _updateText() {
    final updateTimeMs = (_averageUpdateTime / 1000).toStringAsFixed(2);
    final fpsStr = _fps.toStringAsFixed(1);
    
    _textComponent.text = 'FPS: $fpsStr\nUpdate: ${updateTimeMs}ms';
    
    // Change color if performance is dropping
    // 16.6ms is the budget for 60fps. If update takes > 12ms, we are getting close.
    if (_averageUpdateTime > 12000) {
      _textComponent.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
           shadows: [
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
      );
    } else if (_averageUpdateTime > 8000) {
      _textComponent.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 16,
           fontWeight: FontWeight.bold,
           shadows: [
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
      );
    } else {
       _textComponent.textRenderer = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
           fontWeight: FontWeight.bold,
           shadows: [
            Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
          ],
        ),
      );
    }
  }
}

