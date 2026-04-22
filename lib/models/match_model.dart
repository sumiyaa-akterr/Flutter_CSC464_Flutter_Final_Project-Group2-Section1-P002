import 'package:cloud_firestore/cloud_firestore.dart';

class GameMatch {
  final String player1;
  final String player2;
  final String winner; // "X", "O", or "Tie"
  final List<String> board; // Array of length 9
  final DateTime createdAt;

  GameMatch({
    required this.player1,
    required this.player2,
    required this.winner,
    required this.board,
    required this.createdAt,
  });

  // Convert a Dart object into a Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'player1': player1,
      'player2': player2,
      'winner': winner,
      'board': board,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
