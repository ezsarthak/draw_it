import '../entities/drawn_line.dart';
import '../entities/user.dart';

abstract class SocketRepository {
  Future<void> connect();
  Future<void> disconnect();
  void emitDrawLine(DrawnLine line);
  void emitUndo();
  void emitRedo();
  void emitClearCanvas();
  void updateName(String name);
  Stream<DrawnLine> get drawLineStream;
  Stream<void> get undoStream;
  Stream<void> get redoStream;
  Stream<void> get clearCanvasStream;
  Stream<List<User>> get usersUpdateStream;
  Stream<bool> get connectionStream;
  String? get userId;
  bool get isConnected;
}
