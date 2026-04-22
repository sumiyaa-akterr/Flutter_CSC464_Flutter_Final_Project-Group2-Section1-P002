import 'package:flutter/material.dart';

class PlayerNameInput extends StatefulWidget {
  final Function(String, String) onStart;

  const PlayerNameInput({super.key, required this.onStart});

  @override
  State<PlayerNameInput> createState() => _PlayerNameInputState();
}

class _PlayerNameInputState extends State<PlayerNameInput> {
  final TextEditingController _playerXController = TextEditingController();
  final TextEditingController _playerOController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Player Names",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _playerXController,
                decoration: const InputDecoration(
                  labelText: "Player X Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: _playerOController,
                decoration: const InputDecoration(
                  labelText: "Player O Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  String playerXName = _playerXController.text.trim();
                  String playerOName = _playerOController.text.trim();

                  // Only proceed if both names are not empty
                  if (playerXName.isNotEmpty && playerOName.isNotEmpty) {
                    widget.onStart(playerXName, playerOName);
                  }
                },
                child: const Text("Start Game"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerXController.dispose();
    _playerOController.dispose();
    super.dispose();
  }
}
