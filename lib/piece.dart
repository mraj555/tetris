import 'dart:ui';
import 'values.dart';

class Piece {
  Tetromino type;
  List<int> position = [];
  Color get color => tetrominoColors[type]!;
  int rotationState = 0; // 0, 1, 2, 3

  Piece({required this.type});

  void initializePiece() {
    switch (type) {
      case Tetromino.L:
        position = [-26, -16, -6, -5];
        break;
      case Tetromino.J:
        position = [-25, -15, -5, -6];
        break;
      case Tetromino.I:
        position = [-36, -26, -16, -6];
        break;
      case Tetromino.O:
        position = [-16, -15, -6, -5];
        break;
      case Tetromino.S:
        position = [-15, -14, -26, -25];
        break;
      case Tetromino.Z:
        position = [-17, -16, -26, -25];
        break;
      case Tetromino.T:
        position = [-26, -16, -6, -15];
        break;
    }
    // Adjusting Z and S initial positions to look right
    if (type == Tetromino.S) {
      position = [-15, -14, -6, -7];
    } else if (type == Tetromino.Z) {
      position = [-17, -16, -6, -5];
    } else if (type == Tetromino.I) {
      position = [-35, -25, -15, -5];
    }
  }

  void movePiece(Direction direction) {
    switch (direction) {
      case Direction.down:
        for (int i = 0; i < position.length; i++) {
          position[i] += rowLength;
        }
        break;
      case Direction.left:
        for (int i = 0; i < position.length; i++) {
          position[i] -= 1;
        }
        break;
      case Direction.right:
        for (int i = 0; i < position.length; i++) {
          position[i] += 1;
        }
        break;
    }
  }

  // Generate the new positions after a rotation
  // We use the second block as the pivot (index 1) for most pieces
  List<int> getNextRotation() {
    if (type == Tetromino.O) return List.from(position); // O piece does not rotate

    int newRotationState = (rotationState + 1) % 4;
    List<int> newPosition = [];

    switch (type) {
      case Tetromino.L:
        switch (newRotationState) {
          case 0:
            newPosition = [
              position[1] - rowLength,
              position[1],
              position[1] + rowLength,
              position[1] + rowLength + 1,
            ];
            break;
          case 1:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + rowLength - 1,
            ];
            break;
          case 2:
            newPosition = [
              position[1] - rowLength - 1,
              position[1] - rowLength,
              position[1],
              position[1] + rowLength,
            ];
            break;
          case 3:
            newPosition = [
              position[1] - rowLength + 1,
              position[1] - 1,
              position[1],
              position[1] + 1,
            ];
            break;
        }
        break;
      case Tetromino.J:
        switch (newRotationState) {
          case 0:
            newPosition = [
              position[1] - rowLength,
              position[1],
              position[1] + rowLength,
              position[1] + rowLength - 1,
            ];
            break;
          case 1:
            newPosition = [
              position[1] - rowLength - 1,
              position[1] - 1,
              position[1],
              position[1] + 1,
            ];
            break;
          case 2:
            newPosition = [
              position[1] - rowLength + 1,
              position[1] - rowLength,
              position[1],
              position[1] + rowLength,
            ];
            break;
          case 3:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + rowLength + 1,
            ];
            break;
        }
        break;
      case Tetromino.I:
        switch (newRotationState) {
          case 0:
          case 2:
            newPosition = [
              position[1] - rowLength,
              position[1],
              position[1] + rowLength,
              position[1] + 2 * rowLength,
            ];
            break;
          case 1:
          case 3:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + 2,
            ];
            break;
        }
        break;
      case Tetromino.S:
        switch (newRotationState) {
          case 0:
          case 2:
            newPosition = [
              position[1],
              position[1] + 1,
              position[1] + rowLength - 1,
              position[1] + rowLength,
            ];
            break;
          case 1:
          case 3:
            newPosition = [
              position[1] - rowLength,
              position[1],
              position[1] + 1,
              position[1] + rowLength + 1,
            ];
            break;
        }
        break;
      case Tetromino.Z:
        switch (newRotationState) {
          case 0:
          case 2:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + rowLength,
              position[1] + rowLength + 1,
            ];
            break;
          case 1:
          case 3:
            newPosition = [
              position[1] - rowLength + 1,
              position[1] + 1,
              position[1],
              position[1] + rowLength,
            ];
            break;
        }
        break;
      case Tetromino.T:
        switch (newRotationState) {
          case 0:
            newPosition = [
              position[1] - rowLength,
              position[1],
              position[1] + 1,
              position[1] + rowLength,
            ];
            break;
          case 1:
            newPosition = [
              position[1] - 1,
              position[1],
              position[1] + 1,
              position[1] + rowLength,
            ];
            break;
          case 2:
            newPosition = [
              position[1] - rowLength,
              position[1] - 1,
              position[1],
              position[1] + rowLength,
            ];
            break;
          case 3:
            newPosition = [
              position[1] - rowLength,
              position[1] - 1,
              position[1],
              position[1] + 1,
            ];
            break;
        }
        break;
      default:
        return position;
    }
    return newPosition;
  }

  void rotate() {
    position = getNextRotation();
    rotationState = (rotationState + 1) % 4;
  }
}
