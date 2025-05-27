import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/socket_usecases.dart';
import '../../../domain/repositories/socket_repository.dart';
import '../../../domain/entities/user.dart';
import 'socket_event.dart';
import 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final ConnectSocketUseCase connectSocketUseCase;
  final DisconnectSocketUseCase disconnectSocketUseCase;
  final EmitDrawLineUseCase emitDrawLineUseCase;
  final SocketRepository socketRepository;

  StreamSubscription? _drawLineSubscription;
  StreamSubscription? _undoSubscription;
  StreamSubscription? _redoSubscription;
  StreamSubscription? _clearCanvasSubscription;
  StreamSubscription? _usersUpdateSubscription;
  StreamSubscription? _connectionSubscription;

  SocketBloc({
    required this.connectSocketUseCase,
    required this.disconnectSocketUseCase,
    required this.emitDrawLineUseCase,
    required this.socketRepository,
  }) : super(const SocketState()) {
    on<ConnectEvent>(_onConnect);
    on<DisconnectEvent>(_onDisconnect);
    on<EmitDrawLineEvent>(_onEmitDrawLine);
    on<EmitUndoEvent>(_onEmitUndo);
    on<EmitRedoEvent>(_onEmitRedo);
    on<EmitClearCanvasEvent>(_onEmitClearCanvas);
    on<UpdateNameEvent>(_onUpdateName);
    on<_ConnectionChangedEvent>(_onConnectionChanged);
    on<_UsersUpdatedEvent>(_onUsersUpdated);
  }

  Future<void> _onConnect(ConnectEvent event, Emitter<SocketState> emit) async {
    await connectSocketUseCase();
    
    // Set up stream subscriptions
    _connectionSubscription = socketRepository.connectionStream.listen((isConnected) {
      add(_ConnectionChangedEvent(isConnected));
    });

    _usersUpdateSubscription = socketRepository.usersUpdateStream.listen((users) {
      add(_UsersUpdatedEvent(users));
    });
  }

  Future<void> _onDisconnect(DisconnectEvent event, Emitter<SocketState> emit) async {
    await disconnectSocketUseCase();
    _cancelSubscriptions();
    emit(state.copyWith(isConnected: false, userId: null, activeUsers: []));
  }

  void _onEmitDrawLine(EmitDrawLineEvent event, Emitter<SocketState> emit) {
    emitDrawLineUseCase(event.line);
  }

  void _onEmitUndo(EmitUndoEvent event, Emitter<SocketState> emit) {
    socketRepository.emitUndo();
  }

  void _onEmitRedo(EmitRedoEvent event, Emitter<SocketState> emit) {
    socketRepository.emitRedo();
  }

  void _onEmitClearCanvas(EmitClearCanvasEvent event, Emitter<SocketState> emit) {
    socketRepository.emitClearCanvas();
  }

  void _onUpdateName(UpdateNameEvent event, Emitter<SocketState> emit) {
    socketRepository.updateName(event.name);
    emit(state.copyWith(userName: event.name));
  }

  void _onConnectionChanged(_ConnectionChangedEvent event, Emitter<SocketState> emit) {
    emit(state.copyWith(
      isConnected: event.isConnected,
      userId: event.isConnected ? socketRepository.userId : null,
    ));
  }

  void _onUsersUpdated(_UsersUpdatedEvent event, Emitter<SocketState> emit) {
    emit(state.copyWith(activeUsers: event.users));
  }

  void _cancelSubscriptions() {
    _drawLineSubscription?.cancel();
    _undoSubscription?.cancel();
    _redoSubscription?.cancel();
    _clearCanvasSubscription?.cancel();
    _usersUpdateSubscription?.cancel();
    _connectionSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}

// Internal events for handling stream updates
class _ConnectionChangedEvent extends SocketEvent {
  final bool isConnected;

  const _ConnectionChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

class _UsersUpdatedEvent extends SocketEvent {
  final List<User> users;

  const _UsersUpdatedEvent(this.users);

  @override
  List<Object?> get props => [users];
}
