import 'package:flutter/material.dart';

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
