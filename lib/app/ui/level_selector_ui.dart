import 'package:flutter/material.dart';
import '../utils/level_metadata.dart';

class LevelSelectorUI extends StatelessWidget {
  final List<LevelMetadata> levels;
  final int selectedIndex;
  final int bestScore;
  final double bestTime;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onStart;
  final VoidCallback onBack;

  const LevelSelectorUI({
    super.key,
    required this.levels,
    required this.selectedIndex,
    required this.bestScore,
    required this.bestTime,
    required this.onPrev,
    required this.onNext,
    required this.onStart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final level = levels[selectedIndex];

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header / Title
            Text(
              'SELECT LEVEL',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 32,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.cyan.shade400,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            // Selector Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Arrow Button
                IconButton(
                  icon: const Icon(Icons.arrow_left, size: 64, color: Colors.white),
                  onPressed: onPrev,
                ),
                
                const SizedBox(width: 20),

                // Selected Level Panel
                Container(
                  width: 380,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Difficulty
                      Text(
                        level.difficulty.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        level.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      const Divider(color: Colors.white38, thickness: 1),
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BEST SCORE:',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '$bestScore',
                            style: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BEST TIME:',
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${bestTime.toStringAsFixed(2)}s',
                            style: const TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: 14,
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Right Arrow Button
                IconButton(
                  icon: const Icon(Icons.arrow_right, size: 64, color: Colors.white),
                  onPressed: onNext,
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Start & Exit Buttons
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              onPressed: onStart,
              child: const Text(
                'START GAME',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
              ),
              onPressed: onBack,
              child: const Text(
                '<< BACK TO MAIN MENU',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
