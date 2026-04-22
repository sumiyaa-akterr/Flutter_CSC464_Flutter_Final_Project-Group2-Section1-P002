import 'package:flutter/material.dart';

class Scoreboard extends StatelessWidget {
  final int xScore;
  final int oScore;
  final int draws;

  const Scoreboard({
    super.key,
    required this.xScore,
    required this.oScore,
    required this.draws,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scoreColumn('Player X', xScore, Colors.blue),
          _scoreColumn('Draws', draws, Colors.black54),
          _scoreColumn('Player O', oScore, Colors.red),
        ],
      ),
    );
  }

  Widget _scoreColumn(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
