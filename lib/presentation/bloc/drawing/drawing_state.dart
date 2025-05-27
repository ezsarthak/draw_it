import 'package:equatable/equatable.dart';
import '../../../domain/entities/drawn_line.dart';

class DrawingState extends Equatable {
  final List<DrawnLine> lines;
  final List<DrawnLine> undoStack;
  final DrawnLine? currentLine;

  const DrawingState({
    this.lines = const [],
    this.undoStack = const [],
    this.currentLine,
  });

  DrawingState copyWith({
    List<DrawnLine>? lines,
    List<DrawnLine>? undoStack,
    DrawnLine? currentLine,
    bool clearCurrentLine = false,
  }) {
    return DrawingState(
      lines: lines ?? this.lines,
      undoStack: undoStack ?? this.undoStack,
      currentLine: clearCurrentLine ? null : (currentLine ?? this.currentLine),
    );
  }

  @override
  List<Object?> get props => [lines, undoStack, currentLine];
}
