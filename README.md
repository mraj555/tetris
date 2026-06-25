# Tetris Game in Flutter

A fully functional, classic Tetris game built entirely with Flutter. This project demonstrates core game loop implementation, state management, piece rotation algorithms, and gesture-based controls within the Flutter framework.

## Tech Stack
*   **Framework**: Flutter
*   **Language**: Dart
*   **UI/Rendering**: Core Flutter Widgets (`GridView`, `GestureDetector`, `SafeArea`, `AspectRatio`)

## Architecture Overview
The application is structured using a centralized state-driven architecture. The game state is managed locally within the main game board widget, keeping the logic tightly coupled to the render loop for optimal performance and simplicity.

Key architectural concepts implemented:
*   **1D Array Grid**: The 10x20 game board is mapped as a single 1D array (`List<Color?>`), which simplifies rendering via `GridView.builder` while maintaining O(1) lookups for collision detection.
*   **Game Engine Loop**: A `Timer.periodic` acts as the game engine tick, recalculating state (gravity, collisions, line clears) at a set frame rate and triggering `setState()` to repaint the UI.
*   **Mathematical Rotation**: Instead of relying on 2D matrix rotation which can be complex to bound-check, pieces use mathematical coordinate translation (pivot-based offsets) for accurate classic Tetris rotation, preventing pieces from splitting or clipping through walls.
*   **Accumulator Gestures**: Touch controls utilize a `dragAccumulator` pattern via `onPanUpdate` to track continuous finger movement, providing highly responsive swiping over standard discrete "swipe-and-release" gestures.

## Project Structure
```text
lib/
├── main.dart       # Entry point. Sets up the MaterialApp, theme, and loads the GameBoard.
├── values.dart     # Global Configuration. Contains ENUMs for Direction and Tetromino types, board dimensions (10x20), and the color mapping dictionary.
├── piece.dart      # The `Piece` Model. Encapsulates a single Tetromino. Manages its type, current 1D coordinates, color, translation logic (move left/right/down), and the coordinate offset calculations for the 4 rotation states.
└── board.dart      # The Core Game Engine and UI.
                    #   - Contains the `GameBoard` stateful widget.
                    #   - Manages the 1D array `gameBoard` state and score.
                    #   - Houses the `Timer` game loop.
                    #   - Implements bounds checking, `checkCollision()`, and `clearLines()`.
                    #   - Builds the UI including the `AspectRatio` constraint and `GestureDetector` for touch controls.
```

## Module Connections
1.  **`main.dart`** imports `board.dart` to instantiate the primary game screen as the `home` widget.
2.  **`board.dart`** imports `piece.dart` to instantiate the active falling `Piece` object. It delegates movement and rotation tasks to the `Piece` instance (`currentPiece.movePiece()`, `currentPiece.rotate()`) but handles the boundary and collision validation itself.
3.  Both **`board.dart`** and **`piece.dart`** import **`values.dart`** to share global constants like `rowLength`, `colLength`, and the `Tetromino` definitions. This ensures total consistency across the physics engine and the rendering engine.
