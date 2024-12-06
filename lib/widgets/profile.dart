import 'package:flutter/material.dart';

class ProfileIconButton extends StatelessWidget {
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _buildProfileIcon('person@example.com'),
      tooltip: 'Profile',
      onPressed: () {
        _showProfilePopover(context, 'person@example.com');
      },
    );
  }

  // Build the profile icon with the first letter of emailId
  Widget _buildProfileIcon(String emailId) {
    String firstLetter = emailId.isNotEmpty ? emailId[0].toUpperCase() : '';
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color.fromARGB(255, 202, 241, 247),
      child: Text(firstLetter,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  // Method to show the profile popover
  void _showProfilePopover(BuildContext context, String emailId) {
    String firstLetter = emailId.isNotEmpty ? emailId[0].toUpperCase() : '';

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
          300, 50, 10, 10),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                child: Text(firstLetter),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emailId),
                  const SizedBox(height: 5),
                  const Text(
                      'Additional Info'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
