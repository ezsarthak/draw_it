import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../domain/entities/drawn_line.dart';
import '../../domain/entities/user.dart';

abstract class SocketDataSource {
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

class SocketDataSourceImpl implements SocketDataSource {
  io.Socket? _socket;

  final StreamController<DrawnLine> _drawLineController =
      StreamController.broadcast();
  final StreamController<void> _undoController = StreamController.broadcast();
  final StreamController<void> _redoController = StreamController.broadcast();
  final StreamController<void> _clearCanvasController =
      StreamController.broadcast();
  final StreamController<List<User>> _usersUpdateController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController =
      StreamController.broadcast();

  @override
  Future<void> connect() async {
    try {
      _socket = io.io(
        'https://draw-it-server-lr4u.onrender.com',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
        },
      );

      _socket!.onConnect((_) {
        print('Connected to server: ${_socket!.id}');
        _connectionController.add(true);
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from server');
        _connectionController.add(false);
      });

      _socket!.on('users_update', (data) {
        try {
          final users =
              List<Map<String, dynamic>>.from(data)
                  .map(
                    (userData) => User(
                      id: userData['id'] ?? '',
                      name: userData['name'] ?? '',
                    ),
                  )
                  .toList();
          _usersUpdateController.add(users);
        } catch (e) {
          print('Error parsing users_update: $e');
        }
      });

      _socket!.on('draw_line', (data) {
        try {
          final newLine = DrawnLine(
            points: List<Offset>.from(
              (data['points'] as List).map(
                (point) => Offset(
                  (point['dx'] as num).toDouble(),
                  (point['dy'] as num).toDouble(),
                ),
              ),
            ),
            color: Color(data['color'] as int),
            width: (data['width'] as num).toDouble(),
          );
          _drawLineController.add(newLine);
        } catch (e) {
          print('Error parsing draw_line: $e');
        }
      });

      _socket!.on('undo', (_) {
        print('Received undo from server');
        _undoController.add(null);
      });

      _socket!.on('redo', (_) {
        print('Received redo from server');
        _redoController.add(null);
      });

      _socket!.on('clear_canvas', (_) {
        print('Received clear_canvas from server');
        _clearCanvasController.add(null);
      });

      _socket!.connect();
    } catch (e) {
      print('Error connecting to socket: $e');
      _connectionController.add(false);
    }
  }

  @override
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connectionController.add(false);
  }

  @override
  void emitDrawLine(DrawnLine line) {
    if (_socket?.connected == true) {
      print('Emitting draw_line to server');
      _socket!.emit('draw_line', {
        'points': line.points.map((p) => {'dx': p.dx, 'dy': p.dy}).toList(),
        'color': line.color.value,
        'width': line.width,
      });
    }
  }

  @override
  void emitUndo() {
    if (_socket?.connected == true) {
      print('Emitting undo to server');
      _socket!.emit('undo');
    }
  }

  @override
  void emitRedo() {
    if (_socket?.connected == true) {
      print('Emitting redo to server');
      _socket!.emit('redo');
    }
  }

  @override
  void emitClearCanvas() {
    if (_socket?.connected == true) {
      print('Emitting clear_canvas to server');
      _socket!.emit('clear_canvas');
    }
  }

  @override
  void updateName(String name) {
    if (_socket?.connected == true) {
      _socket!.emit('update_name', name);
    }
  }

  @override
  Stream<DrawnLine> get drawLineStream => _drawLineController.stream;

  @override
  Stream<void> get undoStream => _undoController.stream;

  @override
  Stream<void> get redoStream => _redoController.stream;

  @override
  Stream<void> get clearCanvasStream => _clearCanvasController.stream;

  @override
  Stream<List<User>> get usersUpdateStream => _usersUpdateController.stream;

  @override
  Stream<bool> get connectionStream => _connectionController.stream;

  @override
  String? get userId => _socket?.id;

  @override
  bool get isConnected => _socket?.connected ?? false;
}
