class TicTacToeGame {
  // --- The State ---
  List<String> board = List.filled(9, ''); 
  String currentPlayer = 'X';
  String winner = ''; 
  bool isGameOver = false;

  // --- Session Score Tracking ---
  int xWins = 0;
  int oWins = 0;
  int draws = 0;

  // --- Winning Combinations ---
  final List<List<int>> _winningCombos = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
    [0, 4, 8], [2, 4, 6]             // Diagonals
  ];

  // --- The Action ---
  bool makeMove(int index) {
    if (board[index] != '' || isGameOver) {
      return false;
    }

    board[index] = currentPlayer;
    _checkGameState();

    if (!isGameOver) {
      currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
    }
    
    return true;
  }

  // --- The Logic ---
  void _checkGameState() {
    for (var combo in _winningCombos) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[0]] == board[combo[2]]) {
        
        winner = board[combo[0]];
        isGameOver = true;
        
        if (winner == 'X') xWins++;
        if (winner == 'O') oWins++;
        return;
      }
    }

    if (!board.contains('')) {
      winner = 'Draw';
      isGameOver = true;
      draws++;
    }
  }

  // --- The Reset ---
  void resetGame() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    winner = '';
    isGameOver = false;
  }
}