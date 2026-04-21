import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';   
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'models/game_logic.dart';
import 'models/match_model.dart';                   
import 'services/match_service.dart';              
import 'screens/match_history_screen.dart';          
import 'widgets/scoreboard.dart';
import 'firebase_options.dart';                     
// Liya: Made async + added Firebase init
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // must be first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TicTacToeApp());
}

// ─── Sumaya CODE: untouched ──────────────────────────────────────
class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Sumaya's CODE: game logic instance
  final TicTacToeGame _game = TicTacToeGame();

  // Liya TASK 5: player names + starting player state
  String _player1 = 'Player 1';
  String _player2 = 'Player 2';
  String _startingPlayer = 'X'; // who goes first next game

  // Liya TASK 6: called automatically when a game ends
  Future<void> _saveMatchToFirestore() async {
    final match = GameMatch(
      player1: _player1,
      player2: _player2,
      winner: _game.winner,           // 'X', 'O', or 'Draw'
      board: List<String>.from(_game.board), // snapshot of final board
      createdAt: DateTime.now(),
    );
    await MatchService.saveMatch(match);
  }

  // Liya TASK 5c: opens a dialog so players can type new names
  void _showChangeNamesDialog() {
    final ctrl1 = TextEditingController(text: _player1);
    final ctrl2 = TextEditingController(text: _player2);

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
                labelText: 'Player 1 (X)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl2,
              decoration: const InputDecoration(
                labelText: 'Player 2 (O)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _player1 = ctrl1.text.trim().isEmpty ? 'Player 1' : ctrl1.text.trim();
                _player2 = ctrl2.text.trim().isEmpty ? 'Player 2' : ctrl2.text.trim();
              });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        // Liya TASK 6: history button in top-right corner
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Match History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MatchHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Sumaya: SCOREBOARD (TASK 4)
          Scoreboard(
            xScore: _game.xWins,
            oScore: _game.oWins,
            draws: _game.draws,
          ),

          // Liya TASK 5: show whose turn + player names
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _game.isGameOver
                  ? (_game.winner == 'Draw'
                      ? "It's a Draw! 🤝"
                      : '${_game.winner == 'X' ? _player1 : _player2} Wins! 🎉')
                  : "${_game.currentPlayer == 'X' ? _player1 : _player2}'s Turn (${_game.currentPlayer})",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _game.isGameOver ? Colors.green : Colors.deepPurple,
              ),
            ),
          ),

          // Sumaya's CODE: THE SLOT FOR MEMBER 1 (TASK 2)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.deepPurple.withValues(alpha: 0.2), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: const Center(
                child: Text(
                  "Member 1:\nReplace this Container with your\n3x3 GridView here!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ),

          // Liya TASK 5: GAME CONTROLS (replaces her single Reset button)
          Padding(
            padding: const EdgeInsets.only(bottom: 32, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Liya 5a. RESET BOARD ──────────────────────────────
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _game.resetGame(); // calls  resetGame()
                      // reset always sets currentPlayer = 'X'.
                      // Override if 'O' should start:
                      if (_startingPlayer == 'O') {
                        _game.currentPlayer = 'O';
                      }
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Board'),
                ),
                const SizedBox(height: 8),

                // ── Liya 5b. SWITCH STARTING PLAYER ───────────────────
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _startingPlayer =
                          _startingPlayer == 'X' ? 'O' : 'X';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Next game starts with: '
                          '${_startingPlayer == 'X' ? _player1 : _player2} ($_startingPlayer)',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz,
                      color: Colors.deepPurple),
                  label: Text(
                    'Starter: ${_startingPlayer == 'X' ? _player1 : _player2} ($_startingPlayer)',
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 8),

                // ── Liya 5c. CHANGE PLAYER NAMES ──────────────────────
                OutlinedButton.icon(
                  onPressed: _showChangeNamesDialog,
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  label: Text(
                    '$_player1  vs  $_player2',
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}