import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveDigitalClock extends StatefulWidget {
  const LiveDigitalClock({
    super.key,
    this.use24HourFormat,
    this.showSeconds = true,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ),
    this.locale,
  });

  /// null = auto detect from device locale
  final bool? use24HourFormat;

  final bool showSeconds;
  final TextStyle? textStyle;
  final EdgeInsets padding;

  /// Example:
  /// "en_US", "fr_FR"
  final String? locale;

  @override
  State<LiveDigitalClock> createState() => _LiveDigitalClockState();
}

class _LiveDigitalClockState extends State<LiveDigitalClock> {
  late Timer _timer;

  DateTime _now = DateTime.now();

  bool _showColon = true;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        setState(() {
          _now = DateTime.now();

          /// blinking colon
          _showColon = !_showColon;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool _shouldUse24Hour(BuildContext context) {
    if (widget.use24HourFormat != null) {
      return widget.use24HourFormat!;
    }

    return MediaQuery.of(context).alwaysUse24HourFormat;
  }

  String _formatTime(BuildContext context) {
    final locale =
        widget.locale ?? Localizations.localeOf(context).toString();

    final use24Hour = _shouldUse24Hour(context);

    String pattern;

    if (use24Hour) {
      pattern = widget.showSeconds ? 'HH:mm:ss' : 'HH:mm';
    } else {
      pattern = widget.showSeconds ? 'hh:mm:ss a' : 'hh:mm a';
    }

    final formatted = DateFormat(pattern, locale).format(_now);

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      _formatTime(context),
      key: ValueKey(_formatTime(context)),
      style: widget.textStyle ??
          TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: colorScheme.onSurface,
          ),
    );
  }
}