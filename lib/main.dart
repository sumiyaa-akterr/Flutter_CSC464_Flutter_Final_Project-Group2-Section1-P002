import 'package:flutter/material.dart';
import 'models/game_logic.dart';
import 'widgets/scoreboard.dart';

void main() {
  runApp(const TicTacToeApp());
}

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
  // 2. INITIALIZING GAME LOGIC (TASK 3)
  final TicTacToeGame _game = TicTacToeGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 3. CALLING SCOREBOARD (TASK 4)
          Scoreboard(
            xScore: _game.xWins,
            oScore: _game.oWins,
            draws: _game.draws,
          ),

          // 4. THE SLOT FOR MEMBER 1 (TASK 2)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                // This creates a simple border so Member 1 knows where the grid goes
                border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.2), width: 2),
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

          // 5. GAME CONTROLS (TASK 5) 
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _game.resetGame(); // Uses your logic to reset
                });
              },
              child: const Text("Reset Board"),
            ),
          ),
        ],
      ),
    );
  }
}