// import 'package:flutter/material.dart';

// class GameBoard extends StatefulWidget {
//   final String playerXName;
//   final String playerOName;

//   const GameBoard({
//     super.key,
//     required this.playerXName,
//     required this.playerOName,
//   });

//   @override
//   State<GameBoard> createState() => _GameBoardState();
// }

// class _GameBoardState extends State<GameBoard> {
//   List<String> board = List.filled(9, '');
//   String currentPlayer = 'X';

//   void makeMove(int index) {
//     if (board[index] != '') return;

//     setState(() {
//       board[index] = currentPlayer;
//       currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       itemCount: 9,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 1,
//       ),
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () => makeMove(index),
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey.shade400),
//             ),
//             child: Center(
//               child: Text(
//                 board[index],
//                 style: TextStyle(
//                   fontSize: 38,
//                   fontWeight: FontWeight.bold,
//                   color: board[index] == 'X' ? Colors.blue : Colors.red,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';

class GameBoard extends StatefulWidget {
  final String playerXName;
  final String playerOName;

  const GameBoard({
    super.key,
    required this.playerXName,
    required this.playerOName,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  List<String> board = ['', '', '', '', '', '', '', '', ''];
  String currentPlayer = 'X';

  void makeMove(int index) {
    if (board[index] != '') return;
    setState(() {
      board[index] = currentPlayer;
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: List.generate(
            9,
            (index) => GestureDetector(
              onTap: () => makeMove(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Center(
                  child: Text(
                    board[index],
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: board[index] == 'X' ? Colors.blue : Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
