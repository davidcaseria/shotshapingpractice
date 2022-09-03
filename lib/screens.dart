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

  Future<int> _saveShot(WarmUpShot shot) async {
    final provider = await DatabaseProvider.getInstance();
    return await shot.save(provider.db);
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
                    _saveShot(
                        WarmUpShot(session, expectedStartDirection, direction));
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

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<StatefulWidget> createState() =>
      _PracticeScreenState(DirectionExt.random());
}

class _PracticeScreenState extends State<PracticeScreen> {
  Direction expectedStartDirection;
  Direction? actualStartDirection;
  Direction expectedCurveDirection;
  Direction? actualCurveDirection;
  int session = DateTime.now().millisecondsSinceEpoch;
  int score = 0;
  int shot = 0;

  _PracticeScreenState(this.expectedStartDirection)
      : expectedCurveDirection = expectedStartDirection.opposite();

  _nextShot() {
    if (actualStartDirection != null && actualCurveDirection != null) {
      _saveShot(PracticeShot(
          session,
          expectedStartDirection,
          actualStartDirection!,
          expectedCurveDirection,
          actualCurveDirection!));
      int points = 0;
      if (actualStartDirection == expectedStartDirection) {
        points++;
      }
      if (actualCurveDirection == expectedCurveDirection) {
        points++;
      }
      setState(() {
        score += points;
        shot++;
        expectedStartDirection = DirectionExt.random();
        expectedCurveDirection = expectedStartDirection.opposite();
        actualStartDirection = null;
        actualCurveDirection = null;
      });
    }
  }

  Future<int> _saveShot(PracticeShot shot) async {
    final provider = await DatabaseProvider.getInstance();
    return await shot.save(provider.db);
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
                  setState(() {
                    actualStartDirection = direction;
                    _nextShot();
                  });
                },
                label: 'Start Direction',
                expectedDirection: expectedStartDirection,
                actualDirection: actualStartDirection,
              ),
              DirectionCard(
                callback: (direction) {
                  setState(() {
                    actualCurveDirection = direction;
                    _nextShot();
                  });
                },
                label: 'Curve Direction',
                expectedDirection: expectedCurveDirection,
                actualDirection: actualCurveDirection,
              ),
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

class ViewStatsScreen extends StatefulWidget {
  const ViewStatsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ViewStatsScreenState();
}

class _ViewStatsScreenState extends State<ViewStatsScreen> {
  final Future<List<num?>> data = Future.wait([
    ShotStatsModel.getWarmUpPct(Direction.left),
    ShotStatsModel.getWarmUpPct(Direction.right),
    ShotStatsModel.getPracticePct(Direction.left),
    ShotStatsModel.getPracticePct(Direction.right),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<num?>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Warm Up Stats',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .apply(color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      StatsItem(label: 'Left', value: snapshot.data![0]),
                      StatsItem(label: 'Right', value: snapshot.data![1]),
                    ],
                  ),
                  Text(
                    'Practice Stats',
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .apply(color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      StatsItem(label: 'Left/Right', value: snapshot.data![2]),
                      StatsItem(label: 'Right/Left', value: snapshot.data![3]),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Text(
                              'Back',
                              style: TextStyle(fontSize: 24),
                            )),
                      ))
                ]);
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Calculating Stats...'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
