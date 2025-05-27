import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final String? currentUserId;

  const UserList({
    super.key,
    required this.users,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Users:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (users.isEmpty)
            const Text('No users connected')
          else
            Wrap(
              spacing: 8,
              children: users.map((user) {
                final isMe = user.id == currentUserId;
                return Chip(
                  label: Text(user.name.isNotEmpty ? user.name : 'Anonymous'),
                  backgroundColor: isMe ? Colors.blue.shade100 : Colors.grey.shade100,
                  avatar: CircleAvatar(
                    backgroundColor: isMe ? Colors.blue : Colors.grey,
                    child: Text(
                      user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
