// ============================================================
// lib/screens/game_screen.dart
//
// The main game screen. Contains:
//   Task 2 — 3×3 interactive board
//   Task 3 — Turn tracking + result display
//   Task 4 — Scoreboard
//   Task 5 — Game Controls (YOUR PART) ✅
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'match_history_screen.dart'; // Task 6 screen

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  // ── TASK 5c: Show dialog to change player names ───────────
  // This is YOUR part. It opens a popup where players can
  // type new names and save them.
  void _showChangeNamesDialog(BuildContext context) {
    final game = context.read<GameProvider>();
    final ctrl1 = TextEditingController(text: game.player1);
    final ctrl2 = TextEditingController(text: game.player2);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Player Names'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl1,
              decoration: const InputDecoration(
                  labelText: 'Player 1 (X)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl2,
              decoration: const InputDecoration(
                  labelText: 'Player 2 (O)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // ✅ Task 5c — calls changePlayerNames() in GameProvider
              game.changePlayerNames(ctrl1.text, ctrl2.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // consumer<GameProvider> rebuilds whenever notifyListeners() is called
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F0FF),
          appBar: AppBar(
            title: const Text('Tic Tac Toe'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            actions: [
              // Navigate to Match History screen (Task 6)
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Match History',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MatchHistoryScreen()),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── TASK 4: SCOREBOARD ─────────────────────
                _buildScoreboard(game),
                const SizedBox(height: 16),

                // ── TASK 3: TURN / RESULT INDICATOR ────────
                _buildStatusText(game),
                const SizedBox(height: 16),

                // ── TASK 2: 3×3 GAME BOARD ─────────────────
                _buildBoard(context, game),
                const SizedBox(height: 24),

                // ── TASK 5: GAME CONTROLS ← YOUR PART ──────
                _buildGameControls(context, game),
              ],
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // TASK 4 — Scoreboard Widget
  // ----------------------------------------------------------
  Widget _buildScoreboard(GameProvider game) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _scoreColumn(game.player1, game.xWins, Colors.deepPurple),
            _scoreColumn('Draws', game.draws, Colors.grey),
            _scoreColumn(game.player2, game.oWins, Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _scoreColumn(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13, color: color),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('$score',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ----------------------------------------------------------
  // TASK 3 — Status text (whose turn / who won)
  // ----------------------------------------------------------
  Widget _buildStatusText(GameProvider game) {
    String message;
    Color color;

    if (game.winner == 'Draw') {
      message = "It's a Draw! 🤝";
      color = Colors.grey.shade700;
    } else if (game.winner.isNotEmpty) {
      final winnerName =
          game.winner == 'X' ? game.player1 : game.player2;
      message = '$winnerName Wins! 🎉';
      color = Colors.green.shade700;
    } else {
      message = "${game.currentPlayerName}'s Turn (${game.currentTurn})";
      color = Colors.deepPurple;
    }

    return Text(message,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: color),
        textAlign: TextAlign.center);
  }

  // ----------------------------------------------------------
  // TASK 2 — 3×3 Interactive Board
  // ----------------------------------------------------------
  Widget _buildBoard(BuildContext context, GameProvider game) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final cell = game.board[index];
          return GestureDetector(
            onTap: () => context.read<GameProvider>().makeMove(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: cell.isEmpty
                    ? Colors.white
                    : (cell == 'X'
                        ? Colors.deepPurple.shade50
                        : Colors.orange.shade50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.shade200, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2))
                ],
              ),
              child: Center(
                child: Text(
                  cell,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: cell == 'X' ? Colors.deepPurple : Colors.orange,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // ✅ TASK 5 — GAME CONTROLS  ← THIS IS YOUR PART
  // ----------------------------------------------------------
  Widget _buildGameControls(BuildContext context, GameProvider game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Label
        const Text('Game Controls',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
        const SizedBox(height: 10),

        // ── 5a. RESET BOARD ──────────────────────────────────
        // Clears the board so a new round can be played.
        // The starting player is whoever was set last.
        ElevatedButton.icon(
          onPressed: () => context.read<GameProvider>().resetBoard(),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Board'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 10),

        // ── 5b. SWITCH STARTING PLAYER ───────────────────────
        // Toggles who will go first in the NEXT game after reset.
        // Shows the current starting player so it's clear.
        OutlinedButton.icon(
          onPressed: () =>
              context.read<GameProvider>().switchStartingPlayer(),
          icon: const Icon(Icons.swap_horiz, color: Colors.deepPurple),
          label: Text(
            'Switch Starter: ${game.startingPlayerLabel}',
            style: const TextStyle(color: Colors.deepPurple),
          ),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 10),

        // ── 5c. CHANGE PLAYER NAMES ──────────────────────────
        // Opens a dialog where players can type new names.
        OutlinedButton.icon(
          onPressed: () => _showChangeNamesDialog(context),
          icon: const Icon(Icons.edit, color: Colors.deepPurple),
          label: const Text('Change Names',
              style: TextStyle(color: Colors.deepPurple)),
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.deepPurple),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        ),
      ],
    );
  }
}