import '../entities/drawn_line.dart';
import '../repositories/drawing_repository.dart';

class AddLineUseCase {
  final DrawingRepository repository;

  AddLineUseCase(this.repository);

  void call(DrawnLine line) {
    repository.addLine(line);
  }
}

class UndoUseCase {
  final DrawingRepository repository;

  UndoUseCase(this.repository);

  DrawnLine? call() {
    return repository.undo();
  }
}

class RedoUseCase {
  final DrawingRepository repository;

  RedoUseCase(this.repository);

  DrawnLine? call() {
    return repository.redo();
  }
}

class ClearLinesUseCase {
  final DrawingRepository repository;

  ClearLinesUseCase(this.repository);

  void call() {
    repository.clearLines();
  }
}
