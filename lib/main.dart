import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Your internal project imports
import 'models/game_logic.dart';
import 'models/match_model.dart';
import 'services/match_service.dart';
import 'screens/match_history_screen.dart';
import 'widgets/scoreboard.dart';
import 'widgets/game_board.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase is already initialized to prevent the duplicate app error
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase already initialized or error: $e");
  }

  runApp(const TicTacToeApp()); // Make sure this matches your root widget name
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe Pro',
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
  final TicTacToeGame _game = TicTacToeGame();

  String _player1 = 'Player 1';
  String _player2 = 'Player 2';
  String _startingPlayer = 'X';
  bool _hasSavedThisMatch = false; 

  Future<void> _saveMatchToFirestore() async {
    if (_hasSavedThisMatch) return; 
    
    final match = GameMatch(
      player1: _player1,
      player2: _player2,
      winner: _game.winner,
      board: List<String>.from(_game.board),
      createdAt: DateTime.now(),
    );

    await MatchService.saveMatch(match);
    setState(() {
      _hasSavedThisMatch = true;
    });
  }

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
            TextField(controller: ctrl1, decoration: const InputDecoration(labelText: 'Player 1 (X)')),
            const SizedBox(height: 12),
            TextField(controller: ctrl2, decoration: const InputDecoration(labelText: 'Player 2 (O)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Scoreboard(
            xScore: _game.xWins,
            oScore: _game.oWins,
            draws: _game.draws,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _game.isGameOver
                  ? (_game.winner == 'Draw' ? "It's a Draw! 🤝" : '${_game.winner == 'X' ? _player1 : _player2} Wins! 🎉')
                  : "${_game.currentPlayer == 'X' ? _player1 : _player2}'s Turn (${_game.currentPlayer})",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _game.isGameOver ? Colors.green : Colors.deepPurple,
              ),
            ),
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: GameBoard(
                game: _game, 
                onMove: () {
                  setState(() {}); 
                  if (_game.isGameOver && !_hasSavedThisMatch) {
                    _saveMatchToFirestore(); 
                  }
                },
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 32, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _game.resetGame(); 
                      _game.currentPlayer = _startingPlayer; 
                      _hasSavedThisMatch = false; 
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Board'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            // 1. Toggle the variable
                            _startingPlayer = _startingPlayer == 'X' ? 'O' : 'X';
                            
                            // 2. INSTANT SWITCH: If the board is fresh, change current turn immediately
                            bool boardIsEmpty = _game.board.every((cell) => cell == '');
                            if (boardIsEmpty || _game.isGameOver) {
                               _game.currentPlayer = _startingPlayer;
                            } else {
                              // If game is in progress, show a quick tip
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Starting player changed for next reset!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.swap_horiz, color: Colors.deepPurple),
                        label: Text('Starts: $_startingPlayer'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showChangeNamesDialog,
                        icon: const Icon(Icons.edit, color: Colors.deepPurple),
                        label: const Text('Edit Names'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}