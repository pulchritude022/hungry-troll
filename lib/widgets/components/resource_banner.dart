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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Meat Count - fixed width container with right-aligned text
              SizedBox(
                width: 150,
                child: ValueListenableBuilder<int>(
                  valueListenable: gameState.meat,
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'BearDays',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Icon - FractionalTranslation offsets by a fraction of the child's size
              // Original Flame anchor was (0.25, 0.625), geometric center is (0.5, 0.5)
              // Offset = (0.5 - 0.25, 0.5 - 0.625) = (0.25, -0.125)
              FractionalTranslation(
                translation: const Offset(0.25, -0.125),
                child: Image.asset(
                  'assets/images/resources/resources/m_idle.png',
                  width: 128,
                  height: 128,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

