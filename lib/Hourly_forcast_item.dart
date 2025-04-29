import 'package:flutter/material.dart';
class HourlyForacastItem extends StatelessWidget {
  final String time;
  final icon;
  final String temp;
  const HourlyForacastItem({
    super.key,
    required this.time,
    required this.icon,
    required this.temp,


    });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(
              height: 8,
            ),
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              temp,
            ),
          ],
        ),
      ),
    );
  }
}
