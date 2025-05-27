import '../entities/drawn_line.dart';
import '../repositories/socket_repository.dart';

class ConnectSocketUseCase {
  final SocketRepository repository;

  ConnectSocketUseCase(this.repository);

  Future<void> call() {
    return repository.connect();
  }
}

class DisconnectSocketUseCase {
  final SocketRepository repository;

  DisconnectSocketUseCase(this.repository);

  Future<void> call() {
    return repository.disconnect();
  }
}

class EmitDrawLineUseCase {
  final SocketRepository repository;

  EmitDrawLineUseCase(this.repository);

  void call(DrawnLine line) {
    repository.emitDrawLine(line);
  }
}
