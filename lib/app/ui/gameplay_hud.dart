import 'package:flutter/material.dart';

class GameplayHUD extends StatelessWidget {
  final double survivalTime;
  final int currentScore;
  final String phaseName;

  const GameplayHUD({
    super.key,
    required this.survivalTime,
    required this.currentScore,
    required this.phaseName,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: 24,
      right: 24,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel: Survival Metrics
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TIME: ${survivalTime.toStringAsFixed(2)}s',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'SCORE: $currentScore',
                  style: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 14,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),

            // Right Panel: Active Level VM Phase Info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white30, width: 1),
              ),
              child: Text(
                phaseName.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 12,
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
