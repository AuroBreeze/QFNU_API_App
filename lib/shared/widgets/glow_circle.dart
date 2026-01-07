import 'package:flutter/material.dart';

class GlowCircle extends StatelessWidget {
  final Offset offset;
  final double size;
  final List<Color> colors;

  const GlowCircle({
    super.key,
    required this.offset,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
