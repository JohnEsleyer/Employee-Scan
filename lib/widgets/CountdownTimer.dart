import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimer extends StatefulWidget {
  CountdownTimer({
    required this.duration,
    required this.onFinished,
  });

  final int duration;
  final Function onFinished;

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _remainingTime = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _remainingTime = widget.duration;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime == 0) {
        _timer?.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_remainingTime seconds',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }
}
