import 'package:flutter/material.dart';
import 'package:shotshapingpractice/db.dart';

class MenuButton extends StatelessWidget {
  final IconData icon;
  final String name;
  final Widget screen;

  const MenuButton(
      {super.key,
      required this.icon,
      required this.name,
      required this.screen});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        icon: Icon(icon),
        label: Text(
          name,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class Scorecard extends StatelessWidget {
  final int score;
  final int shot;
  const Scorecard({super.key, required this.score, required this.shot});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ScorecardItem(label: 'Score', value: score),
        ScorecardItem(label: 'Shot', value: shot),
      ],
    );
  }
}

class ScorecardItem extends StatelessWidget {
  final String label;
  final int value;
  const ScorecardItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          '$value',
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.headline5,
        )
      ],
    );
  }
}

typedef DirectionCallback = Function(Direction direction);

class DirectionCard extends StatefulWidget {
  final DirectionCallback callback;
  final String label;
  final Direction direction;
  const DirectionCard(
      {super.key,
      required this.callback,
      required this.label,
      required this.direction});

  @override
  State<StatefulWidget> createState() => _DirectionCardState();
}

class _DirectionCardState extends State<DirectionCard> {
  Direction? actualDirection;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.headline4,
            )),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              widget.direction.label(),
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  ?.apply(color: Colors.black),
            )),
        Padding(
            padding: const EdgeInsets.all(10),
            child: DirectionCardRadioGroup(
                callback: (direction) => setState(() {
                      actualDirection = direction;
                      widget.callback(direction);
                    }),
                expectedDirection: widget.direction,
                actualDirection: actualDirection))
      ],
    );
  }
}

class DirectionCardRadioGroup extends StatelessWidget {
  final DirectionCallback callback;
  final Direction expectedDirection;
  final Direction? actualDirection;
  const DirectionCardRadioGroup(
      {super.key,
      required this.callback,
      required this.expectedDirection,
      required this.actualDirection});

  Color _color(Direction direction) {
    if (actualDirection == null || direction != actualDirection) {
      return Colors.grey;
    } else if (direction == actualDirection && direction == expectedDirection) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        DirectionCardRadioButton(
            direction: Direction.left,
            callback: (() => callback(Direction.left)),
            color: _color(Direction.left)),
        DirectionCardRadioButton(
            direction: Direction.right,
            callback: (() => callback(Direction.right)),
            color: _color(Direction.right)),
      ],
    );
  }
}

class DirectionCardRadioButton extends StatelessWidget {
  final Direction direction;
  final VoidCallback callback;
  final Color color;
  const DirectionCardRadioButton(
      {super.key,
      required this.direction,
      required this.callback,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        onPressed: () => callback(),
        child: Padding(
            padding: const EdgeInsets.all(50),
            child: Text(
              direction.label(),
              style: TextStyle(fontSize: 24, color: color),
            )));
  }
}
