import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

class SocketState extends Equatable {
  final bool isConnected;
  final List<User> activeUsers;
  final String? userId;
  final String userName;

  const SocketState({
    this.isConnected = false,
    this.activeUsers = const [],
    this.userId,
    this.userName = '',
  });

  SocketState copyWith({
    bool? isConnected,
    List<User>? activeUsers,
    String? userId,
    String? userName,
  }) {
    return SocketState(
      isConnected: isConnected ?? this.isConnected,
      activeUsers: activeUsers ?? this.activeUsers,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
    );
  }

  @override
  List<Object?> get props => [isConnected, activeUsers, userId, userName];
}
