import 'package:flutter/material.dart';

class Additonal_info extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  const Additonal_info({
    super.key,
    required this.icon,
    required this.label,
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
       icon,
        const SizedBox(
          height: 9,
        ),
        Text(label),
        const SizedBox(
          height: 9,
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
      ],
    );
  }
}
