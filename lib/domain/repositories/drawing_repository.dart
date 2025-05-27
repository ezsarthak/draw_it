import '../entities/drawn_line.dart';

abstract class DrawingRepository {
  List<DrawnLine> getLines();
  List<DrawnLine> getUndoStack();
  void addLine(DrawnLine line);
  DrawnLine? undo();
  DrawnLine? redo();
  void clearLines();
  void setCurrentLine(DrawnLine? line);
  DrawnLine? getCurrentLine();
}
