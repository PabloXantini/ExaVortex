import 'package:flutter/material.dart';

class GameOverUI extends StatelessWidget {
  final double survivalTime;
  final int score;
  final bool isNewRecord;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const GameOverUI({
    super.key,
    required this.survivalTime,
    required this.score,
    required this.isNewRecord,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Crash Title
            Text(
              'GAME OVER',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontSize: 36,
                color: Colors.red.shade600,
                shadows: [
                  Shadow(
                    blurRadius: 15,
                    color: Colors.redAccent.shade400,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Performance Container
            Container(
              width: 360,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isNewRecord ? Colors.amber : Colors.red.shade800,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  if (isNewRecord) ...[
                    // New Record Banner
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      color: Colors.amber,
                      child: const Text(
                        'NEW HIGH SCORE!',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SURVIVED:',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '${survivalTime.toStringAsFixed(2)}s',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),

                  // Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SCORE:',
                        style: TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontFamily: 'PressStart2P',
                          fontSize: 16,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Navigation Options
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: onRetry,
              child: const Text(
                'TRY AGAIN',
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
                foregroundColor: Colors.white60,
              ),
              onPressed: onExit,
              child: const Text(
                'EXIT TO SELECTOR',
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
