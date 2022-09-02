import 'package:flutter/material.dart';
import 'package:shotshapingpractice/components.dart';
import 'package:shotshapingpractice/db.dart';

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

class WarmUpScreen extends StatefulWidget {
  const WarmUpScreen({super.key});

  @override
  State<StatefulWidget> createState() => _WarmUpScreenState();
}

class _WarmUpScreenState extends State<WarmUpScreen> {
  Direction expectedStartDirection = DirectionExt.random();
  int session = DateTime.now().millisecondsSinceEpoch;
  int score = 0;
  int shot = 0;

  Future<int> _saveShot(Direction direction) async {
    final provider = await DatabaseProvider.getInstance();
    return await WarmUpShot(session, expectedStartDirection, direction)
        .save(provider.db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Scorecard(score: score, shot: shot),
              DirectionCard(
                  callback: (direction) {
                    _saveShot(direction);
                    int points = 0;
                    if (direction == expectedStartDirection) {
                      points++;
                    }
                    setState(() {
                      score += points;
                      shot++;
                      expectedStartDirection = DirectionExt.random();
                    });
                  },
                  label: 'Start Direction',
                  expectedDirection: expectedStartDirection),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      'End Session',
                      style: TextStyle(fontSize: 24),
                    )),
              )
            ]),
      ),
    );
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
