# 🎮 Tic-Tac-Toe Pro (Flutter + Firebase)

A fully integrated, cross-platform Tic-Tac-Toe application built with Flutter and powered by Firebase. This project was developed as a collaborative team effort, featuring real-time game logic, persistent match history, and a modern Material 3 UI.

---

## ✨ Final Features

* **Custom Player Profiles:** Interactive dialogs to set custom names for Player X and Player O.
* **Smart Game Engine:** Automated win and draw detection with a real-time scoreboard tracking X Wins, O Wins, and Draws.
* **Cloud Match History:** Every completed game is automatically synced to **Firebase Firestore** with details on the winner and final board state.
* **Dynamic Controls:** Features a "Reset Board" functionality and a toggle to choose which player starts the next match.
* **Polished UI:** A responsive 3x3 game board utilizing `AspectRatio` for a perfect square grid across all devices.

---

## 🛠️ Tech Stack & Architecture

* **Frontend:** [Flutter](https://flutter.dev/) (Material 3)
* **Backend/Database:** [Google Firebase Firestore](https://firebase.google.com/docs/firestore)
* **State Management:** `setState` with a centralized `TicTacToeGame` logic class.
* **Architecture:** Modular file structure for better maintainability:
    * `lib/models/`: Game logic and Match data models.
    * `lib/widgets/`: Reusable UI components (Board, Scoreboard).
    * `lib/services/`: Firebase Firestore integration logic.
    * `lib/screens/`: Navigation and History screens.

---

## 🚀 Getting Started

To run this project locally, ensure you have Flutter installed and follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone [YOUR_GITHUB_URL_HERE]
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Firebase Configuration:**
    The project includes a pre-configured `firebase_options.dart` file. Ensure you are targeting a supported platform (Web, Android, or iOS).
4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 👥 Team Contributions

The project was executed using a modular "Feature-Branch" workflow:

* **Ummay Humaira Rashid (Setup & Board):** Designed the core interactive 3x3 grid and the player name entry systems.
* **Sumiya Akter (Logic & Scoreboard):** Developed the win/draw algorithms and the persistent scoreboard UI.
* **Kazi Fabiha Golam Liya (Controls & Cloud):** Implemented the Firestore match history persistence, game reset controls, and led the final project integration.

---

## 🎨 Design System

The app adheres to **Material 3** standards, utilizing a deep purple color scheme. All widgets are styled dynamically through the `ThemeData` to ensure a consistent, modern aesthetic across the entire user experience.

---

### **Final Project Status: RELEASED**
The project was successfully merged from `develop` into `main` after thorough integration testing. All features are verified and functional.