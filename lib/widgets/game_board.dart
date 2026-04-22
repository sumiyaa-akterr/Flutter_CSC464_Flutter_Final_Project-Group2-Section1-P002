import 'package:flutter/material.dart';
import '../models/game_logic.dart';

class GameBoard extends StatelessWidget {
  final TicTacToeGame game;
  final VoidCallback onMove;

  const GameBoard({super.key, required this.game, required this.onMove});

  @override
  Widget build(BuildContext context) {
    // 1. Center the board so it doesn't hug the top
    return Center(
      // 2. AspectRatio forces the board to be a perfect square 
      // preventing those "long bars" from your screenshot.
      child: AspectRatio(
        aspectRatio: 1.0, 
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          // 3. Add spacing so the cells don't touch
          crossAxisSpacing: 8,
          mainAxisSpacing: 8, 
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(9, (index) => GestureDetector(
            onTap: () {
              // Only trigger move if the cell is empty and game is active
              if (game.board[index] == '' && !game.isGameOver) {
                game.makeMove(index);
                onMove();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  game.board[index],
                  style: TextStyle(
                    fontSize: 48, // Slightly larger for better visibility
                    fontWeight: FontWeight.bold,
                    color: game.board[index] == 'X' ? Colors.deepPurple : Colors.orange,
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}