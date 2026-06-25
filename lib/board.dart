import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'piece.dart';
import 'values.dart';

// A single block on the grid
class Pixel extends StatelessWidget {
  final Color color;
  const Pixel({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.all(1),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // Grid: null if empty, Color if filled
  List<Color?> gameBoard = List.generate(rowLength * colLength, (i) => null);

  // Active piece
  Piece currentPiece = Piece(type: Tetromino.L);

  int currentScore = 0;
  bool isGameOver = false;

  Timer? gameTimer;

  // For swipe gestures
  double dragAccumulatorX = 0;
  double dragAccumulatorY = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();

    // Start frame refresh
    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(
      frameRate,
      (timer) {
        setState(() {
          clearLines();
          checkLanding();
          if (isGameOver) {
            timer.cancel();
            showGameOverDialog();
          } else {
            currentPiece.movePiece(Direction.down);
          }
        });
      },
    );
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score is: $currentScore'),
        actions: [
          TextButton(
            onPressed: () {
              resetGame();
              Navigator.pop(context);
            },
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard = List.generate(rowLength * colLength, (i) => null);
    isGameOver = false;
    currentScore = 0;
    createNewPiece();
    startGame();
  }

  bool checkCollision(Direction direction) {
    // Loop through each position of current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // Check boundaries
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      // Check if another piece is there (only if we're on the board)
      if (row >= 0 && col >= 0) {
        int newIndex = row * rowLength + col;
        if (gameBoard[newIndex] != null) {
          return true;
        }
      }
    }
    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      // Mark position as occupied
      for (int i = 0; i < currentPiece.position.length; i++) {
        int index = currentPiece.position[i];
        if (index >= 0 && index < rowLength * colLength) {
          gameBoard[index] = currentPiece.color;
        }
      }

      // Check game over
      if (currentPiece.position.any((pos) => pos < 0)) {
        isGameOver = true;
      } else {
        createNewPiece();
      }
    }
  }

  void createNewPiece() {
    Random random = Random();
    Tetromino randomType = Tetromino.values[random.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      // Try to rotate
      List<int> newPosition = currentPiece.getNextRotation();
      
      // Check if new position is valid
      bool isValid = true;
      for (int pos in newPosition) {
        int row = (pos / rowLength).floor();
        int col = pos % rowLength;
        
        // Out of bounds
        if (row >= colLength || col < 0 || col >= rowLength) {
          isValid = false;
          break;
        }
        
        // Collision with existing blocks
        if (pos >= 0 && pos < rowLength * colLength && gameBoard[pos] != null) {
          isValid = false;
          break;
        }
      }
      
      if (isValid) {
        currentPiece.rotate();
      }
    });
  }

  void clearLines() {
    int linesCleared = 0;
    
    for (int row = colLength - 1; row >= 0; row--) {
      bool isRowFull = true;
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row * rowLength + col] == null) {
          isRowFull = false;
          break;
        }
      }

      if (isRowFull) {
        linesCleared++;
        // Move everything down
        for (int r = row; r > 0; r--) {
          for (int c = 0; c < rowLength; c++) {
            gameBoard[r * rowLength + c] = gameBoard[(r - 1) * rowLength + c];
          }
        }
        // Clear top row
        for (int c = 0; c < rowLength; c++) {
          gameBoard[c] = null;
        }
        // Check this row again (since things moved down into it)
        row++;
      }
    }
    
    if (linesCleared > 0) {
      currentScore += linesCleared * 100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                moveLeft();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                moveRight();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                // Soft drop
                setState(() {
                  checkLanding();
                  if (!isGameOver) {
                    currentPiece.movePiece(Direction.down);
                  }
                });
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                rotatePiece();
              }
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score at top left
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Score: $currentScore',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: rowLength / colLength,
                    child: GestureDetector(
                      onTap: rotatePiece,
                  onPanStart: (details) {
                    dragAccumulatorX = 0;
                    dragAccumulatorY = 0;
                  },
                  onPanUpdate: (details) {
                    dragAccumulatorX += details.delta.dx;
                    dragAccumulatorY += details.delta.dy;

                    // Horizontal movement
                    if (dragAccumulatorX.abs() > 40) {
                      if (dragAccumulatorX > 0) {
                        moveRight();
                      } else {
                        moveLeft();
                      }
                      dragAccumulatorX = 0; // Reset after moving
                    }

                    // Vertical movement (soft drop)
                    if (dragAccumulatorY > 40) {
                      setState(() {
                        checkLanding();
                        if (!isGameOver) {
                          currentPiece.movePiece(Direction.down);
                        }
                      });
                      dragAccumulatorY = 0; // Reset after dropping
                    }
                  },
                  child: GridView.builder(
                    itemCount: rowLength * colLength,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength,
                    ),
                    itemBuilder: (context, index) {
                      // Background
                      Color? color = gameBoard[index];

                      // Active piece
                      if (currentPiece.position.contains(index)) {
                        color = currentPiece.color;
                      }

                      return Pixel(
                        color: color ?? Colors.grey[900]!,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
