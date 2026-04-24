// TASK 6 — Liya: code for saving match results to Firestore and loading
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

class MatchService {
  // Get a reference to the 'matches' collection in Firestore
  // This maps to: /matches/{matchId} in Firebase console
  static final _collection =
      FirebaseFirestore.instance.collection('matches');

  // ── SAVE a match result to Firestore ──────────────────────
  // Called after every game ends. Creates a new document in
  // the 'matches' collection with the result and timestamp.
  static Future<void> saveMatch(GameMatch match) async {
    try {
      // .add() creates a new document with an auto-generated ID
      await _collection.add(match.toMap());
      print('Match saved successfully!');
    } catch (e) {
      // Don't crash the app if saving fails — just log it
      print('Error saving match: $e');
    }
  }

  // ── LOAD all matches from Firestore ───────────────────────
  // Returns a Stream: this means the UI updates automatically
  // whenever new data is added to Firestore (real-time).
  // Sorted: newest match first.
  static Stream<List<GameMatch>> getMatches() {
    return _collection
        .orderBy('createdAt', descending: true) // newest first
        .snapshots() // listen for real-time changes
        .map((snapshot) {
      // Convert each Firestore document → GameMatch object
      return snapshot.docs.map((doc) {
        return GameMatch.fromMap(doc.data());
      }).toList();
    });
  }
}