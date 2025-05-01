import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final int value;
  const Tile({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value == 0 ? Colors.grey[300] : _getTileColor(value),
        borderRadius: BorderRadius.circular(10),
      ),
      child: value == 0
          ? null
          : Text(
        '$value',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: value > 4 ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Function to determine tile color based on value
  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.orange[100]!;
      case 4:
        return Colors.orange[200]!;
      case 8:
        return Colors.orange[400]!;
      case 16:
        return Colors.orange[600]!;
      case 32:
        return Colors.orange[800]!;
      case 64:
        return Colors.red[400]!;
      case 128:
        return Colors.red[600]!;
      case 256:
        return Colors.red[800]!;
      case 512:
        return Colors.green[400]!;
      case 1024:
        return Colors.green[600]!;
      case 2048:
        return Colors.green[800]!;
      default:
        return Colors.grey[500]!;
    }
  }
}
