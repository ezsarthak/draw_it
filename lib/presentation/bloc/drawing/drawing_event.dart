import 'package:equatable/equatable.dart';
import '../../../domain/entities/drawn_line.dart';

abstract class DrawingEvent extends Equatable {
  const DrawingEvent();

  @override
  List<Object?> get props => [];
}

class AddLineEvent extends DrawingEvent {
  final DrawnLine line;

  const AddLineEvent(this.line);

  @override
  List<Object?> get props => [line];
}

class UpdateCurrentLineEvent extends DrawingEvent {
  final DrawnLine? line;

  const UpdateCurrentLineEvent(this.line);

  @override
  List<Object?> get props => [line];
}

class UndoEvent extends DrawingEvent {
  const UndoEvent();
}

class RedoEvent extends DrawingEvent {
  const RedoEvent();
}

class ClearLinesEvent extends DrawingEvent {
  const ClearLinesEvent();
}

class AddRemoteLineEvent extends DrawingEvent {
  final DrawnLine line;

  const AddRemoteLineEvent(this.line);

  @override
  List<Object?> get props => [line];
}

class RemoteUndoEvent extends DrawingEvent {
  const RemoteUndoEvent();
}

class RemoteRedoEvent extends DrawingEvent {
  const RemoteRedoEvent();
}

class RemoteClearLinesEvent extends DrawingEvent {
  const RemoteClearLinesEvent();
}
