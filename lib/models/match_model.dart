import 'package:cloud_firestore/cloud_firestore.dart';

class GameMatch {
  final String player1;
  final String player2;
  final String winner; // "X", "O", or "Draw"
  final List<String> board; // Array of length 9
  final DateTime createdAt;

  GameMatch({
    required this.player1,
    required this.player2,
    required this.winner,
    required this.board,
    required this.createdAt,
  });

  // Convert Dart object → Firestore (for SAVING)
  Map<String, dynamic> toMap() {
    return {
      'player1': player1,
      'player2': player2,
      'winner': winner,
      'board': board,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  //  Convert Firestore → Dart object (for READING in Task 6)
  // This was missing — match_service.dart needs this to load history.
  factory GameMatch.fromMap(Map<String, dynamic> data) {
    return GameMatch(
      player1: data['player1'] ?? '',
      player2: data['player2'] ?? '',
      winner: data['winner'] ?? '',
      board: List<String>.from(data['board'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}