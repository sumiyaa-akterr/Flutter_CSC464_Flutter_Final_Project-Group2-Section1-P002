// File: lib/models/game_model.dart
class GameModel {
  List<String> board;
  String currentPlayer;
  String playerXName;
  String playerOName;

  GameModel({
    required this.board,
    required this.currentPlayer,
    required this.playerXName,
    required this.playerOName,
  });

  // Initial game state
  factory GameModel.initial() {
    return GameModel(
      board: List.filled(9, ''),
      currentPlayer: 'X',
      playerXName: 'Player X',
      playerOName: 'Player O',
    );
  }

  // Copy with method for updating state
  GameModel copyWith({
    List<String>? board,
    String? currentPlayer,
    String? playerXName,
    String? playerOName,
  }) {
    return GameModel(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      playerXName: playerXName ?? this.playerXName,
      playerOName: playerOName ?? this.playerOName,
    );
  }
}
