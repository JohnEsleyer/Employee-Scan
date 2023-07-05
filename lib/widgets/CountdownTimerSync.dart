import 'package:employee_scan/widgets/FadeAnimationWidget.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CountdownTimerSync extends StatefulWidget {
  CountdownTimerSync({
    required this.duration,
    required this.onFinished,
  });

  final int duration;
  final Function onFinished;

  @override
  _CountdownTimerSyncState createState() => _CountdownTimerSyncState();
}

class _CountdownTimerSyncState extends State<CountdownTimerSync> {
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

    _startTimer();
  }

  void _startTimer() {
    _remainingTime = widget.duration;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime == 0) {
        _timer?.cancel();
        widget.onFinished();
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimationWidget(
      child: Text(
        '$_remainingTime seconds',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}