import 'package:draw_new/core/utils/dimensions.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final String? currentUserId;

  const UserList({super.key, required this.users, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final Dimensions appDimension = Dimensions(context);

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey.shade200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Users:',
            style: TextStyle(
              fontFamily: Dimensions.font,
              fontSize: appDimension.h6,
              fontWeight: Dimensions.fontBold,
            ),
          ),
          const SizedBox(height: 4),
          if (users.isEmpty)
            Text(
              'No users connected',
              style: TextStyle(
                fontFamily: Dimensions.font,
                fontSize: appDimension.h6,
                fontWeight: Dimensions.fontBold,
              ),
            )
          else
            Wrap(
              spacing: 8,
              children:
                  users.map((user) {
                    final isMe = user.id == currentUserId;
                    return Chip(
                      label: Text(
                        user.name.isNotEmpty ? user.name : 'Anonymous',
                        style: TextStyle(
                          fontFamily: Dimensions.font,
                          fontSize: appDimension.h7,
                          fontWeight: Dimensions.fontRegular,
                        ),
                      ),
                      backgroundColor:
                          isMe ? Colors.blue.shade100 : Colors.grey.shade100,
                      avatar: CircleAvatar(
                        backgroundColor: isMe ? Colors.blue : Colors.grey,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name.substring(0, 1).toUpperCase()
                              : '?',
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
