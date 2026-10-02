import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShiftTimeline extends StatefulWidget {
  const ShiftTimeline({
    super.key,
    required this.startTime,
    required this.restTime,
    required this.endTime,
    this.warningMinutes = 30,
  });

  final DateTime startTime;
  final DateTime restTime;
  final DateTime endTime;
  final int warningMinutes;

  @override
  State<ShiftTimeline> createState() => _ShiftTimelineState();
}

class _ShiftTimelineState extends State<ShiftTimeline>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ticker fires every frame (~60fps) — smooth continuous progress
    _ticker = createTicker((_) {
      setState(() => _now = DateTime.now());
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _progress(DateTime from, DateTime to) {
    if (_now.isBefore(from)) return 0.0;
    if (_now.isAfter(to)) return 1.0;
    final total = to.difference(from).inMicroseconds;
    final elapsed = _now.difference(from).inMicroseconds;
    return elapsed / total;
  }

  bool get _isWarning {
    final remaining = widget.endTime.difference(_now);
    return remaining.inMinutes <= widget.warningMinutes &&
        _now.isBefore(widget.endTime);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatLabel(DateTime dt) {
    if (_now.isBefore(dt)) {
      final diff = dt.difference(_now);
      if (diff.inHours > 0) {
        return 'in ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
      }
      return 'in ${diff.inMinutes}m';
    }
    if (_now.isAfter(dt)) {
      final diff = _now.difference(dt);
      if (diff.inHours > 0) {
        return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m ago';
      }
      return '${diff.inMinutes}m ago';
    }
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final p1 = _progress(widget.startTime, widget.restTime);
    final p2 = _progress(widget.restTime, widget.endTime);

    final activeColor = colorScheme.secondary;
    final inactiveColor = colorScheme.onSurface.withOpacity(0.3);
    final seg2Color = _isWarning ? colorScheme.error : activeColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Session Progress',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 48,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _NodeDot(active: true, color: activeColor),
                Expanded(
                  child: _SmoothProgressBar(
                    progress: p1,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                  ),
                ),
                _NodeDot(
                  active: p1 >= 1.0,
                  color: activeColor,
                  isMiddle: true,
                  icon: LucideIcons.circle,
                  size: 20,
                ),
                Expanded(
                  child: _SmoothProgressBar(
                    progress: p2,
                    activeColor: seg2Color,
                    inactiveColor: inactiveColor,
                  ),
                ),
                _NodeDot(active: p2 >= 1.0, color: seg2Color,
                    icon: LucideIcons.check),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              _TimeLabel(
                time: _formatTime(widget.startTime),
                sub: _formatLabel(widget.startTime),
                align: TextAlign.left,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
              const Spacer(),
              _TimeLabel(
                time: _formatTime(widget.restTime),
                sub: 'Mid',
                align: TextAlign.center,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
              const Spacer(),
              _TimeLabel(
                time: _formatTime(widget.endTime),
                sub: _formatLabel(widget.endTime),
                align: TextAlign.right,
                textTheme: textTheme,
                colorScheme: colorScheme,
                isWarning: _isWarning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Smooth progress bar ───────────────────────────────────────────────────────
// Uses a plain FractionallySizedBox — progress is already smooth because the
// parent rebuilds every frame. No AnimatedContainer needed (it adds lag).

class _SmoothProgressBar extends StatelessWidget {
  const _SmoothProgressBar({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            // Track
            Container(color: inactiveColor),
            // Fill — FractionallySizedBox updates every frame without transition lag
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Node dot ──────────────────────────────────────────────────────────────────

class _NodeDot extends StatelessWidget {
  const _NodeDot({
    required this.active,
    required this.color,
    this.isMiddle = false,
    this.icon = LucideIcons.rocket,
    this.size = 40,
  });

  final bool active;
  final Color color;
  final double size;
  final bool isMiddle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
    Theme.of(context).colorScheme.onSurface.withOpacity(0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : Colors.transparent,
        border: Border.all(
          color: active ? color : inactiveColor,
          width: isMiddle ? 2.5 : 2,
        ),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: active ? Colors.white : color,
    ),
    );
  }
}

// ── Time label ────────────────────────────────────────────────────────────────

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({
    required this.time,
    required this.sub,
    required this.align,
    required this.textTheme,
    required this.colorScheme,
    this.isWarning = false,
  });

  final String time;
  final String sub;
  final TextAlign align;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.left
          ? CrossAxisAlignment.start
          : align == TextAlign.right
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        Text(
          time,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
            color: isWarning ? colorScheme.error : colorScheme.onSurface,
          ),
        ),
        Text(
          sub,
          style: textTheme.labelSmall?.copyWith(
            color: isWarning
                ? colorScheme.error.withOpacity(0.8)
                : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

DateTime getMidpoint(DateTime start, DateTime end) {
  final totalMicroseconds = end.difference(start).inMicroseconds;
  return start.add(Duration(microseconds: totalMicroseconds ~/ 2));
}