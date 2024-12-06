import 'package:flutter/material.dart';
import 'package:practice_management/widgets/drawer_item.dart';
import 'package:practice_management/widgets/logout.dart';

class NavigationMenu extends StatelessWidget {
  final Function(int) updateBodyCallback;

  const NavigationMenu({super.key, required this.updateBodyCallback});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: const Color.fromARGB(255, 255, 246, 246),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20, 24, 0),
          child: Column(
            children: [
              headerWidget(),
              const SizedBox(height: 40),
              // const Divider(thickness: 1, height: 10, color: Colors.grey),
              // const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    DrawerItem(
                      name: 'Practice Group Data',
                      icon: Icons.group,
                      onPressed: () => onItemPressed(context, index: 3),
                    ),
                    DrawerItem(
                      name: 'Summary',
                      icon: Icons.summarize,
                      onPressed: () => onItemPressed(context, index: 0),
                    ),
                  ],
                ),
              ),

              // Logout Button
              Align(
                alignment: Alignment.bottomCenter,
                child: DrawerItem(
                  name: 'Log out',
                  icon: Icons.logout,
                  onPressed: () => LogoutDialog.showLogoutDialog(
                      context), // Show the logout dialog
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onItemPressed(BuildContext context, {required int index}) {
    Navigator.pop(context); 
    updateBodyCallback(
        index);
  }

  Widget headerWidget() {
    return const Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('../../assets/images/download.png'),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cognine Technologies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                Text(
                  'Practice Management',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 80, 80, 80),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20), 
        Divider(thickness: 1, height: 10, color: Colors.grey),
      ],
    );
  }
}
