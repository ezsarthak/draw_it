import 'package:draw_new/domain/entities/drawn_line.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/drawing_usecases.dart';
import 'drawing_event.dart';
import 'drawing_state.dart';

class DrawingBloc extends Bloc<DrawingEvent, DrawingState> {
  final AddLineUseCase addLineUseCase;
  final UndoUseCase undoUseCase;
  final RedoUseCase redoUseCase;
  final ClearLinesUseCase clearLinesUseCase;

  DrawingBloc({
    required this.addLineUseCase,
    required this.undoUseCase,
    required this.redoUseCase,
    required this.clearLinesUseCase,
  }) : super(const DrawingState()) {
    on<AddLineEvent>(_onAddLine);
    on<UpdateCurrentLineEvent>(_onUpdateCurrentLine);
    on<UndoEvent>(_onUndo);
    on<RedoEvent>(_onRedo);
    on<ClearLinesEvent>(_onClearLines);
    on<AddRemoteLineEvent>(_onAddRemoteLine);
    on<RemoteUndoEvent>(_onRemoteUndo);
    on<RemoteRedoEvent>(_onRemoteRedo);
    on<RemoteClearLinesEvent>(_onRemoteClearLines);
  }

  void _onAddLine(AddLineEvent event, Emitter<DrawingState> emit) {
    addLineUseCase(event.line);
    emit(
      state.copyWith(
        lines: [...state.lines, event.line],
        undoStack: [], // Clear undo stack when new action is performed
        clearCurrentLine: true,
      ),
    );
  }

  void _onUpdateCurrentLine(
    UpdateCurrentLineEvent event,
    Emitter<DrawingState> emit,
  ) {
    emit(state.copyWith(currentLine: event.line));
  }

  void _onUndo(UndoEvent event, Emitter<DrawingState> emit) {
    if (state.lines.isNotEmpty) {
      final lineToUndo = state.lines.last;
      final newLines = List<DrawnLine>.from(state.lines)..removeLast();
      final newUndoStack = [...state.undoStack, lineToUndo];

      emit(state.copyWith(lines: newLines, undoStack: newUndoStack));
    }
  }

  void _onRedo(RedoEvent event, Emitter<DrawingState> emit) {
    if (state.undoStack.isNotEmpty) {
      final lineToRedo = state.undoStack.last;
      final newLines = [...state.lines, lineToRedo];
      final newUndoStack = List<DrawnLine>.from(state.undoStack)..removeLast();

      emit(state.copyWith(lines: newLines, undoStack: newUndoStack));
    }
  }

  void _onClearLines(ClearLinesEvent event, Emitter<DrawingState> emit) {
    clearLinesUseCase();
    emit(
      state.copyWith(
        lines: [],
        undoStack: [], // Clear both lines and undo stack for clear operation
      ),
    );
  }

  void _onAddRemoteLine(AddRemoteLineEvent event, Emitter<DrawingState> emit) {
    // For remote lines, add them and clear undo stack to maintain consistency
    emit(
      state.copyWith(
        lines: [...state.lines, event.line],
        undoStack: [], // Clear undo stack when remote changes occur
      ),
    );
  }

  void _onRemoteUndo(RemoteUndoEvent event, Emitter<DrawingState> emit) {
    // Handle remote undo - remove the last line and clear undo stack
    if (state.lines.isNotEmpty) {
      final newLines = List<DrawnLine>.from(state.lines)..removeLast();
      emit(
        state.copyWith(
          lines: newLines,
          undoStack: [], // Clear undo stack when remote undo occurs
        ),
      );
    }
  }

  void _onRemoteRedo(RemoteRedoEvent event, Emitter<DrawingState> emit) {
    // Remote redo is handled by receiving the line again via AddRemoteLineEvent
    // Clear undo stack to maintain consistency
    emit(state.copyWith(undoStack: []));
  }

  void _onRemoteClearLines(
    RemoteClearLinesEvent event,
    Emitter<DrawingState> emit,
  ) {
    // Handle remote clear - clear all lines and undo stack
    emit(state.copyWith(lines: [], undoStack: []));
  }
}
