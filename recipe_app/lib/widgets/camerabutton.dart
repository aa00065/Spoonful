import 'package:flutter/material.dart';

class IconBox extends StatelessWidget {
  const IconBox({
    Key? key,
    required this.child,
    this.bgColor = Colors.white,
    this.onTap,
    this.borderColor = Colors.transparent,
    this.radius = 50,
    this.padding = 5,
    this.isShadow = true,
    required this.onIngredientsDetected, // Add this line
  }) : super(key: key);

  final Widget child;
  final Color borderColor;
  final Color bgColor;
  final double radius;
  final double padding;
  final GestureTapCallback? onTap;
  final bool isShadow;
  final Function(List<String>) onIngredientsDetected; // Add this line

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (isShadow)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
          ],
        ),
        child: child,
      ),
    );
  }
}
