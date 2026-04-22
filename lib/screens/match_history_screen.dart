// TASK 6 — Match History Display  ← Liya's part
//
// Shows all previously played matches fetched from Firestore.
// Uses a StreamBuilder so the list updates in real-time
// whenever a new match is saved.
// ============================================================

import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  // Formats DateTime without needing the intl package
  // Example output: "Apr 21, 2026  9:30 PM"
  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour == 0
        ? 12
        : dt.hour > 12
            ? dt.hour - 12
            : dt.hour;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month]} ${dt.day}, ${dt.year}  $hour:$min $ampm';
  }

  // Helper: pick a color based on who won
  Color _winnerColor(String winner) {
    if (winner == 'X') return Colors.deepPurple;
    if (winner == 'O') return Colors.orange;
    return Colors.grey; // Draw
  }

  String _resultText(GameMatch match) {
    if (match.winner == 'Draw') return "It's a Draw!";
    final winnerName = match.winner == 'X' ? match.player1 : match.player2;
    return '$winnerName won (${match.winner})';
  }

  // Draws a tiny 3×3 board showing the final state of the match
  Widget _miniBoard(List<String> board) {
    return SizedBox(
      width: 72,
      height: 72,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          final cell = board.length > i ? board[i] : '';
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple.shade100),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text(
                cell,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color:
                      cell == 'X' ? Colors.deepPurple : Colors.orange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F0FF),
      appBar: AppBar(
        title: const Text('Match History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // ── StreamBuilder listens to Firestore in real-time ───
      // Every time a new match is saved, this widget rebuilds
      // automatically without needing to refresh the page.
      body: StreamBuilder<List<GameMatch>>(
        stream: MatchService.getMatches(), // ← calls your service
        builder: (context, snapshot) {
          // State 1: Still loading data from Firestore
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // State 2: Something went wrong
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading history: ${snapshot.error}'),
            );
          }

          final matches = snapshot.data ?? [];

          // State 3: No matches saved yet
          if (matches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('No matches yet!',
                      style:
                          TextStyle(fontSize: 18, color: Colors.black54)),
                  SizedBox(height: 8),
                  Text('Play a game and results will appear here.',
                      style: TextStyle(color: Colors.black38)),
                ],
              ),
            );
          }

          // State 4: We have matches — show them in a list
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
          return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Left: mini board snapshot
                      _miniBoard(match.board),
                      const SizedBox(width: 14),

                      // Right: match info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Match number (newest = #1)
                            Text(
                              'Match #${matches.length - index}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black38),
                            ),
                            const SizedBox(height: 2),

                            // Players
                            Text(
                              '${match.player1}  vs  ${match.player2}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),

                            // Result
                            Text(
                              _resultText(match),
                              style: TextStyle(
                                color: _winnerColor(match.winner),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Timestamp — formatted manually (no intl package needed)
                            Text(
                              _formatDate(match.createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}