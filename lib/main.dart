// import 'package:flutter/material.dart';
// import 'package:tic_tac_toe_app/widgets/game_board.dart';
// import 'package:tic_tac_toe_app/widgets/player_name_input.dart';
// import 'models/game_logic.dart';
// import 'widgets/scoreboard.dart';

// void main() {
//   runApp(const TicTacToeApp());
// }

// class TicTacToeApp extends StatelessWidget {
//   const TicTacToeApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Tic Tac Toe',
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const GamePage(),
//     );
//   }
// }

// class GamePage extends StatefulWidget {
//   const GamePage({super.key});

//   @override
//   State<GamePage> createState() => _GamePageState();
// }

// class _GamePageState extends State<GamePage> {
//   // 2. INITIALIZING GAME LOGIC (TASK 3)
//   final TicTacToeGame _game = TicTacToeGame();

//   // PLAYER INPUT FLOW
//   String playerX = "";
//   String playerO = "";
//   bool gameStarted = false;

//   void startGame(String x, String o) {
//     setState(() {
//       playerX = x;
//       playerO = o;
//       gameStarted = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Tic Tac Toe'), centerTitle: true),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),

//           // 3. CALLING SCOREBOARD (TASK 4)
//           Scoreboard(
//             xScore: _game.xWins,
//             oScore: _game.oWins,
//             draws: _game.draws,
//           ),

//           // 4. THE SLOT FOR MEMBER 1 (TASK 2)
//           //PLAYER INPUT + GAME BOARD FLOW
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   color: Colors.deepPurple.withValues(alpha: 0.2),
//                   width: 2,
//                 ),
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.grey.shade50,
//               ),

//               child: gameStarted
//                   ? GameBoard(playerXName: playerX, playerOName: playerO)
//                   : PlayerNameInput(onStart: startGame),
//             ),
//           ),

//           // 5. GAME CONTROLS (TASK 5)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 40),
//             child: ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _game.resetGame(); // Uses your logic to reset
//                 });
//               },
//               child: const Text("Reset Board"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/widgets/game_board.dart';
import 'package:tic_tac_toe_app/widgets/player_name_input.dart';
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
      home: const PlayerPage(),
    );
  }
}

// PAGE 1 → PLAYER INPUT

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe'), centerTitle: true),
      body: PlayerNameInput(
        onStart: (x, o) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(playerX: x, playerO: o),
            ),
          );
        },
      ),
    );
  }
}

//PAGE 2 → GAME SCREEN (Scoreboard + Board)

class GamePage extends StatefulWidget {
  final String playerX;
  final String playerO;

  const GamePage({super.key, required this.playerX, required this.playerO});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final TicTacToeGame _game = TicTacToeGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe'), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Scoreboard
          Scoreboard(
            xScore: _game.xWins,
            oScore: _game.oWins,
            draws: _game.draws,
          ),

          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepPurple.withValues(alpha: 0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: GameBoard(
                playerXName: widget.playerX,
                playerOName: widget.playerO,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _game.resetGame();
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
