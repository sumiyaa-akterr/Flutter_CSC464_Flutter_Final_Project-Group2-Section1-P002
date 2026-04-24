import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Your internal project imports
import 'models/game_logic.dart';
import 'models/match_model.dart';
import 'services/match_service.dart';
import 'screens/match_history_screen.dart';
import 'widgets/scoreboard.dart';
import 'widgets/game_board.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TicTacToeApp());
}

// ─── App Theme Colors ──────────────────────────────────────────
class AppColors {
  static const background   = Color(0xFF0D0D1A); // deep navy-black
  static const surface      = Color(0xFF1A1A2E); // card background
  static const surfaceLight = Color(0xFF16213E); // slightly lighter surface
  static const neonX        = Color(0xFF00F5FF); // cyan for X
  static const neonO        = Color(0xFFFF6B6B); // coral-red for O
  static const accent       = Color(0xFF7C3AED); // vivid purple
  static const accentGlow   = Color(0xFF9D5CF6); // lighter purple for glow
  static const gold         = Color(0xFFFFD700); // winner gold
  static const textPrimary  = Color(0xFFE2E8F0);
  static const textMuted    = Color(0xFF64748B);
  static const gridLine     = Color(0xFF2D2D4E);
}

// ─── Reusable Glow Decoration ─────────────────────────────────
BoxDecoration glowBox({
  required Color color,
  double blur = 18,
  double spread = 0,
  BorderRadius? radius,
}) =>
    BoxDecoration(
      borderRadius: radius ?? BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: color.withOpacity(0.35), blurRadius: blur, spreadRadius: spread),
      ],
    );

// ─── TicTacToeApp ─────────────────────────────────────────────
class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe Pro',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.neonX,
          surface: AppColors.surface,
        ),
        fontFamily: 'monospace',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.gridLine, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gridLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gridLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textMuted),
        ),
      ),
      home: const GamePage(),
    );
  }
}

// ─── GamePage ─────────────────────────────────────────────────
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final TicTacToeGame _game = TicTacToeGame();

  String _player1 = 'Player 1';
  String _player2 = 'Player 2';
  String _startingPlayer = 'X';
  bool _hasSavedThisMatch = false;

  // ── Animations ──────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _statusController;
  late Animation<double> _statusFade;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _statusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _statusFade = CurvedAnimation(parent: _statusController, curve: Curves.easeOut);
    _statusController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  // ── Trigger status re-animation on state change ────────────
  void _animateStatus() {
    _statusController.forward(from: 0);
  }

  // ── Save match (unchanged logic) ────────────────────────────
  Future<void> _saveMatchToFirestore() async {
    if (_hasSavedThisMatch) return;
    final match = GameMatch(
      player1: _player1,
      player2: _player2,
      winner: _game.winner,
      board: List<String>.from(_game.board),
      createdAt: DateTime.now(),
    );
    await MatchService.saveMatch(match);
    setState(() => _hasSavedThisMatch = true);
  }

  // ── Change names dialog (unchanged logic, restyled) ─────────
  void _showChangeNamesDialog() {
    final ctrl1 = TextEditingController(text: _player1);
    final ctrl2 = TextEditingController(text: _player2);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded, color: AppColors.accentGlow, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'EDIT PLAYERS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _labeledField(ctrl1, 'Player 1', AppColors.neonX, 'X'),
              const SizedBox(height: 16),
              _labeledField(ctrl2, 'Player 2', AppColors.neonO, 'O'),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _player1 = ctrl1.text.trim().isEmpty ? 'Player 1' : ctrl1.text.trim();
                          _player2 = ctrl2.text.trim().isEmpty ? 'Player 2' : ctrl2.text.trim();
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('SAVE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeledField(TextEditingController ctrl, String label, Color color, String badge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Text(badge,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        ),
      ],
    );
  }

  // ── Status banner ────────────────────────────────────────────
  Widget _buildStatusBanner() {
    final isOver = _game.isGameOver;
    final isDraw = _game.winner == 'Draw';
    final winnerName = _game.winner == 'X' ? _player1 : _player2;
    final currentName = _game.currentPlayer == 'X' ? _player1 : _player2;
    final color = isOver
        ? (isDraw ? AppColors.textMuted : (_game.winner == 'X' ? AppColors.neonX : AppColors.neonO))
        : (_game.currentPlayer == 'X' ? AppColors.neonX : AppColors.neonO);

    String emoji;
    String line1;
    String line2;

    if (!isOver) {
      emoji = '⚡';
      line1 = '$currentName\'s Turn';
      line2 = _game.currentPlayer;
    } else if (isDraw) {
      emoji = '🤝';
      line1 = 'DRAW!';
      line2 = 'No winner this time';
    } else {
      emoji = '🏆';
      line1 = '$winnerName Wins!';
      line2 = '${_game.winner} takes the round';
    }

    return FadeTransition(
      opacity: _statusFade,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 20, spreadRadius: 0)],
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(scale: isOver ? 1.0 : _pulseAnim.value, child: child),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line1,
                    style: TextStyle(
                        color: color, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                Text(line2, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Score pills ──────────────────────────────────────────────
  Widget _buildScoreSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gridLine, width: 1),
      ),
      child: Row(
        children: [
          _scorePill(_player1, 'X', _game.xWins, AppColors.neonX),
          _divider(),
          _scorePill('Draws', '=', _game.draws, AppColors.textMuted),
          _divider(),
          _scorePill(_player2, 'O', _game.oWins, AppColors.neonO),
        ],
      ),
    );
  }

  Widget _scorePill(String name, String badge, int score, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(badge,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
          const SizedBox(height: 6),
          Text(
            '$score',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 48,
        color: AppColors.gridLine,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );

  // ── Game board wrapper ───────────────────────────────────────
  Widget _buildBoard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gridLine, width: 1.5),
          boxShadow: [
            BoxShadow(color: AppColors.accent.withOpacity(0.08), blurRadius: 40, spreadRadius: 0),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: GameBoard(
            game: _game,
            onMove: () {
              setState(() {});
              _animateStatus();
              if (_game.isGameOver && !_hasSavedThisMatch) {
                _saveMatchToFirestore();
              }
            },
          ),
        ),
      ),
    );
  }

  // ── Bottom controls ──────────────────────────────────────────
  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reset button — primary action
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _game.resetGame();
                _game.currentPlayer = _startingPlayer;
                _hasSavedThisMatch = false;
                _animateStatus();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shadowColor: AppColors.accent.withOpacity(0.5),
              elevation: 8,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('NEW ROUND'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Swap starting player
              Expanded(
                child: _ghostButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'STARTS: ${_startingPlayer}',
                  color: _startingPlayer == 'X' ? AppColors.neonX : AppColors.neonO,
                  onTap: () {
                    setState(() {
                      _startingPlayer = _startingPlayer == 'X' ? 'O' : 'X';
                      bool boardIsEmpty = _game.board.every((cell) => cell == '');
                      if (boardIsEmpty || _game.isGameOver) {
                        _game.currentPlayer = _startingPlayer;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Starting player set for next round!'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.surface,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Edit names
              Expanded(
                child: _ghostButton(
                  icon: Icons.edit_rounded,
                  label: 'EDIT NAMES',
                  color: AppColors.textMuted,
                  onTap: _showChangeNamesDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ghostButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('✕○', style: TextStyle(fontSize: 14, letterSpacing: -2)),
          ),
          const SizedBox(width: 10),
          const Text('TIC TAC TOE', style: TextStyle(fontSize: 17, letterSpacing: 3)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MatchHistoryScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gridLine),
              ),
              child: const Icon(Icons.history_rounded, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildScoreSection(),
          const SizedBox(height: 8),
          _buildStatusBanner(),
          _buildBoard(),
          _buildControls(),
        ],
      ),
    );
  }
}