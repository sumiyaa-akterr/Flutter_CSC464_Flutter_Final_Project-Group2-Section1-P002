# 🎮 Tic-Tac-Toe App (Flutter + Firebase)

Welcome to the project! This repository contains our shared code. Firebase is already connected, and the base Flutter app is fully set up. 

## 🚀 How to Start Working

**Do not run `flutter create`!** The app is already created. Follow these exact steps to get the code on your computer:

1. **Clone the repository:**
   `git clone [PASTE_YOUR_GITHUB_URL_HERE]`
2. **Open the folder in VS Code.**
3. **Download all the Firebase packages:**
   Open your terminal and run: `flutter pub get`
4. **Fetch the team branches:**
   Run: `git fetch`

---

## 🌿 Our Git Workflow

We are using a **Pull Request (PR)** system. You cannot push code directly to `main` or `develop`. 

1. Find your assigned task below and switch to your specific branch:
   `git checkout [your-branch-name]`
2. Write your code and test it locally.
3. Commit and push your changes to your branch:
   `git add .`
   `git commit -m "brief description of what you did"`
   `git push`
4. Go to GitHub and click **"Compare & pull request"** to merge your branch into `develop`. 

---

## 📋 Team Assignments & Branches

Each task has a dedicated branch already waiting for you.

### **Member 1: Setup & Board (The "Face")**
* **Task 1: Name Entry Screen** * Branch: `feat/player-names`
  * Goal: Build the UI to let players enter their names before the game starts.
* **Task 2: 3x3 Interactive Grid**
  * Branch: `feat/game-board`
  * Goal: Build the visual Tic-Tac-Toe board that users can tap.

### **Member 2: Logic & Scoreboard (The "Brain")**
* **Task 3: Win/Tie Detection**
  * Branch: `feat/game-logic`
  * Goal: Write the Dart rules to detect when someone gets 3-in-a-row or a tie.
* **Task 4: Scoreboard UI**
  * Branch: `feat/scoreboard`
  * Goal: Build the UI to display how many games X has won, O has won, and ties.

### **Member 3: Controls & Cloud (The "Memory")**
* **Task 5: Game Controls**
  * Branch: `feat/game-controls`
  * Goal: Add "Reset Game" and "Switch Starting Player" buttons.
* **Task 6: Firebase Match History**
  * Branch: `feat/match-history`
  * Goal: Save finished game data to Firestore and build a UI to display past matches.

---

## 🎨 Design Rules
To keep our app from looking messy, please do not hardcode random colors! Use the standard Material widgets (`ElevatedButton`, `Text`) and they will automatically style themselves based on our global theme in `main.dart`.