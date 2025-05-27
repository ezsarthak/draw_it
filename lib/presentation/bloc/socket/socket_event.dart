import 'package:equatable/equatable.dart';
import '../../../domain/entities/drawn_line.dart';

abstract class SocketEvent extends Equatable {
  const SocketEvent();

  @override
  List<Object?> get props => [];
}

class ConnectEvent extends SocketEvent {
  const ConnectEvent();
}

class DisconnectEvent extends SocketEvent {
  const DisconnectEvent();
}

class EmitDrawLineEvent extends SocketEvent {
  final DrawnLine line;

  const EmitDrawLineEvent(this.line);

  @override
  List<Object?> get props => [line];
}

class EmitUndoEvent extends SocketEvent {
  const EmitUndoEvent();
}

class EmitRedoEvent extends SocketEvent {
  const EmitRedoEvent();
}

class EmitClearCanvasEvent extends SocketEvent {
  const EmitClearCanvasEvent();
}

class UpdateNameEvent extends SocketEvent {
  final String name;

  const UpdateNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}
