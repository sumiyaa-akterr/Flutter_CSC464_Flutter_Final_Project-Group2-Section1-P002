// ============================================================
// lib/providers/game_provider.dart
//
// This wraps your teammate's TicTacToeGame class in a Provider
// so the UI can react to changes automatically.
//
// Her class handles:  board logic, win/draw detection, scores
// Your class handles: player names, starting player, controls,
//                     Firestore saving (Tasks 5 & 6)
// ============================================================

import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/match_service.dart';
import '../models/game_logic.dart'; // ← her file lives in lib/models/

class GameProvider extends ChangeNotifier {
  // Create ONE instance of her game class
  final TicTacToeGame _game = TicTacToeGame();

  // ----------------------------------------------------------
  // YOUR DATA (Task 5)
  // ----------------------------------------------------------
  String _player1 = 'Player 1';
  String _player2 = 'Player 2';
  String _startingPlayer = 'X'; // who goes first next game

  // ----------------------------------------------------------
  // GETTERS — screens read her game's state through these
  // ----------------------------------------------------------
  String get player1 => _player1;
  String get player2 => _player2;
  List<String> get board => List.unmodifiable(_game.board);
  String get currentTurn => _game.currentPlayer;
  String get winner => _game.winner; // 'X', 'O', 'Draw', or ''
  bool get isGameOver => _game.isGameOver;
  int get xWins => _game.xWins;
  int get oWins => _game.oWins;
  int get draws => _game.draws; // she uses 'draws' not 'ties'
  String get startingPlayer => _startingPlayer;

  String get currentPlayerName =>
      _game.currentPlayer == 'X' ? _player1 : _player2;

  String get startingPlayerLabel =>
      _startingPlayer == 'X' ? '$_player1 (X)' : '$_player2 (O)';

  // ----------------------------------------------------------
  // MAKE A MOVE — calls her makeMove(), then checks if done
  // ----------------------------------------------------------
  void makeMove(int index) {
    final moved = _game.makeMove(index); // her method returns bool
    if (!moved) return; // she returned false = invalid move

    if (_game.isGameOver) {
      _saveMatchToFirestore(); // Task 6: auto-save when game ends
    }

    notifyListeners(); // tell all screens to rebuild
  }

  // ===========================================================
  // ✅ TASK 5 — GAME CONTROLS  ← YOUR PART
  // ===========================================================

  // ── 5a. RESET BOARD ────────────────────────────────────────
  // Calls her resetGame(), then applies the correct starting
  // player (her reset always defaults to 'X', so we fix it).
  void resetBoard() {
    _game.resetGame(); // clears board, sets currentPlayer = 'X'

    // Her resetGame() always sets currentPlayer to 'X'.
    // If we want 'O' to start, we manually override it here.
    if (_startingPlayer == 'O') {
      _game.currentPlayer = 'O';
    }

    notifyListeners();
  }

  // ── 5b. SWITCH STARTING PLAYER ─────────────────────────────
  // Toggles _startingPlayer between 'X' and 'O'.
  // Takes effect the NEXT time resetBoard() is called.
  void switchStartingPlayer() {
    _startingPlayer = _startingPlayer == 'X' ? 'O' : 'X';
    notifyListeners();
  }

  // ── 5c. CHANGE PLAYER NAMES ────────────────────────────────
  void changePlayerNames(String name1, String name2) {
    _player1 = name1.trim().isEmpty ? 'Player 1' : name1.trim();
    _player2 = name2.trim().isEmpty ? 'Player 2' : name2.trim();
    notifyListeners();
  }

  // ===========================================================
  // ✅ TASK 6 — SAVE MATCH TO FIRESTORE  ← YOUR PART
  // ===========================================================
  Future<void> _saveMatchToFirestore() async {
    final match = GameMatch(
      player1: _player1,
      player2: _player2,
      winner: _game.winner, // will be 'X', 'O', or 'Draw'
      board: List<String>.from(_game.board),
      createdAt: DateTime.now(),
    );
    await MatchService.saveMatch(match);
  }
}