import 'package:flutter/material.dart';
import '../../state/game_state.dart';

class ResourceBanner extends StatelessWidget {
  final GameState gameState;

  const ResourceBanner({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Banner Background
          Image.asset(
            'assets/images/ui/banners/banner_horizontal.png',
            //scale: 2.0,
            centerSlice: const Rect.fromLTWH(64, 64, 64, 64),
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.only(bottom: 10), // Adjust alignment visually
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Meat Count
                ValueListenableBuilder<int>(
                  valueListenable: gameState.meat,
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: const TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BearDays',
                        // Add shadow/outline if needed to match previous style
                      ),
                    );
                  },
                ),
                const SizedBox(width: 5),
                // Icon
                Image.asset(
                  'assets/images/resources/resources/m_idle.png',
                  width: 96,
                  height: 96,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

