import 'package:flutter/material.dart';



class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const NeumorphicButton({
    required this.onPressed,
    required this.child,
  });

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        width: 150.0,
        height: 50.0,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.grey[400] as Color,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 6.0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey[400] as Color,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 6.0,
                  ),
                ],
        ),
        child: Center(
          child: widget.child,
        ),
      ),
    );
  }
}