import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.duration,
    required this.isAlmostTime,
    this.showSeconds = true,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    this.onFinished,
    this.onTick,
  });

  final Duration duration;
  final bool showSeconds;
  final bool isAlmostTime;
  final TextStyle? textStyle;
  final EdgeInsets padding;
  final VoidCallback? onFinished;
  final Function(Duration)? onTick;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;
  bool _showColon = true;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 0) {
        _timer.cancel();
        setState(() => _showColon = true);
        widget.onFinished?.call();
        return;
      }

      setState(() {
        _remaining -= const Duration(seconds: 1);
        _showColon = !_showColon;
      });

      widget.onTick?.call(_remaining);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime() {
    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final colon = ':';
    //_showColon ? ':' : ' ';

    if (hours > 0) {
      return '${_pad(hours)}$colon${_pad(minutes)}$colon${_pad(seconds)}';
    }

    if (widget.showSeconds) {
      return '${_pad(minutes)}$colon${_pad(seconds)}';
    }

    return '${_pad(hours > 0 ? hours : minutes)}$colon${_pad(minutes > 0 ? minutes : seconds)}';
  }

  String _pad(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isWarning = widget.isAlmostTime;
    final color = isWarning ? Color(0xFFC52D25)
        : isDarkMode ? Colors.white : colorScheme.onSurface;

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final effectiveStyle = widget.textStyle ??
        TextStyle(
          fontSize: 43,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
          color: color,
          fontFeatures: [FontFeature.tabularFigures()],
        );

    Widget digitPair(int value) => SizedBox(
      width: effectiveStyle.fontSize! * 1.35,
      child: Text(
        _pad(value),
        style: effectiveStyle,
        textAlign: TextAlign.center,
      ),
    );

    Widget colon() => SizedBox(
      width: effectiveStyle.fontSize! * 0.5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          isWarning ? _showColon ? ' ' : ':' : ':',
          style: effectiveStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hours > 0) ...[
            digitPair(hours),
            colon(),
          ],
          digitPair(minutes),
          colon(),
          digitPair(seconds),
        ],
      ),
    );
  }
}