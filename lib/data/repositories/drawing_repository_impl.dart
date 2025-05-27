import '../../domain/entities/drawn_line.dart';
import '../../domain/repositories/drawing_repository.dart';

class DrawingRepositoryImpl implements DrawingRepository {
  final List<DrawnLine> _lines = [];
  final List<DrawnLine> _undoStack = [];
  DrawnLine? _currentLine;

  @override
  List<DrawnLine> getLines() => List.unmodifiable(_lines);

  @override
  List<DrawnLine> getUndoStack() => List.unmodifiable(_undoStack);

  @override
  void addLine(DrawnLine line) {
    _lines.add(line);
    _undoStack.clear(); // Clear redo stack when new action is performed
  }

  @override
  DrawnLine? undo() {
    if (_lines.isNotEmpty) {
      final lineToUndo = _lines.removeLast();
      _undoStack.add(lineToUndo);
      return lineToUndo;
    }
    return null;
  }

  @override
  DrawnLine? redo() {
    if (_undoStack.isNotEmpty) {
      final lineToRedo = _undoStack.removeLast();
      _lines.add(lineToRedo);
      return lineToRedo;
    }
    return null;
  }

  @override
  void clearLines() {
    // Move all current lines to undo stack before clearing
    _undoStack.addAll(_lines);
    _lines.clear();
  }

  @override
  void setCurrentLine(DrawnLine? line) {
    _currentLine = line;
  }

  @override
  DrawnLine? getCurrentLine() => _currentLine;
}
