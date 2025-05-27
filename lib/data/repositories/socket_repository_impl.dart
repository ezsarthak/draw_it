import 'dart:async';
import '../../domain/entities/drawn_line.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/socket_repository.dart';
import '../datasources/socket_datasource.dart';

class SocketRepositoryImpl implements SocketRepository {
  final SocketDataSource _dataSource;

  SocketRepositoryImpl(this._dataSource);

  @override
  Future<void> connect() => _dataSource.connect();

  @override
  Future<void> disconnect() => _dataSource.disconnect();

  @override
  void emitDrawLine(DrawnLine line) => _dataSource.emitDrawLine(line);

  @override
  void emitUndo() => _dataSource.emitUndo();

  @override
  void emitRedo() => _dataSource.emitRedo();

  @override
  void emitClearCanvas() => _dataSource.emitClearCanvas();

  @override
  void updateName(String name) => _dataSource.updateName(name);

  @override
  Stream<DrawnLine> get drawLineStream => _dataSource.drawLineStream;

  @override
  Stream<void> get undoStream => _dataSource.undoStream;

  @override
  Stream<void> get redoStream => _dataSource.redoStream;

  @override
  Stream<void> get clearCanvasStream => _dataSource.clearCanvasStream;

  @override
  Stream<List<User>> get usersUpdateStream => _dataSource.usersUpdateStream;

  @override
  Stream<bool> get connectionStream => _dataSource.connectionStream;

  @override
  String? get userId => _dataSource.userId;

  @override
  bool get isConnected => _dataSource.isConnected;
}
