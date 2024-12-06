import 'package:flutter/material.dart';
import 'package:practice_management/screens/practice_group_data.dart';
import 'package:practice_management/screens/summary.dart';
import 'package:practice_management/widgets/profile.dart';
import 'package:practice_management/widgets/side_nav.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _currentBody = const PracticeGroup();

  // Method to change the body content
  void _updateBody(int index) {
    setState(() {
      switch (index) {
        case 0:
          _currentBody = const SummarySection();
          break;
        case 3:
          _currentBody = const PracticeGroup();
          break;
        default:
          _currentBody = const Center(
            child: Text(
              "Feature Coming Soon!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
        actions: const [ProfileIconButton()],
      ),
      drawer: NavigationMenu(updateBodyCallback: _updateBody),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentBody,
      ),
    );
  }
}
