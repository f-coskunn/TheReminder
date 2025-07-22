import 'package:flutter/material.dart';

class ColorfulDecorator extends StatelessWidget {
  final Widget child;
  final Color color;
  const ColorfulDecorator(this.child,{this.color =Colors.transparent,super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: child,
    );
  }
}