import 'package:flutter/material.dart';
import 'package:shotshapingpractice/components.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.fromLTRB(50, 100, 50, 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const <Widget>[
                MenuButton(
                    icon: Icons.sports_golf_rounded,
                    name: 'Warm Up',
                    screen: WarmUpScreen()),
                MenuButton(
                    icon: Icons.scoreboard_rounded,
                    name: 'Practice',
                    screen: PracticeScreen()),
                MenuButton(
                    icon: Icons.bar_chart_rounded,
                    name: 'View Stats',
                    screen: ViewStatsScreen()),
              ],
            )));
  }
}

class WarmUpScreen extends StatelessWidget {
  const WarmUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Warm Up Screen'),
    )));
  }
}

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Practice Screen'),
    )));
  }
}

class ViewStatsScreen extends StatelessWidget {
  const ViewStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('View Stats Screen'),
    )));
  }
}
